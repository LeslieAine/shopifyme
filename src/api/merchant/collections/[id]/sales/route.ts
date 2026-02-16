import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import {
  createPriceListsWorkflow,
  createPriceListPricesWorkflow,
} from "@medusajs/medusa/core-flows"
import { pool } from "../../../../../lib/db"

type Body = {
  title: string
  percentage: number // e.g. 10 = 10% off
}

export async function POST(
  req: AuthenticatedMedusaRequest<Body>,
  res: MedusaResponse
) {
  const merchantService = req.scope.resolve("merchant")
  const query = req.scope.resolve("query")

  const merchantId = req.auth_context?.actor_id
  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated as merchant"
    )
  }

  const merchant = await merchantService.retrieveMerchant(merchantId)

  if (!merchant.sales_channel_id || !merchant.store_id) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Merchant not properly configured"
    )
  }

  const collectionId = req.params.id
  const { title, percentage } = req.body

  if (!title || percentage == null) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "title and percentage are required"
    )
  }

  if (percentage <= 0 || percentage >= 100) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "percentage must be between 1 and 99"
    )
  }

  // 1️⃣ Verify collection belongs to merchant
  const collectionCheck = await pool.query(
    `
    SELECT id
    FROM merchant_collections
    WHERE id = $1
      AND sales_channel_id = $2
    `,
    [collectionId, merchant.sales_channel_id]
  )

  if (collectionCheck.rowCount === 0) {
    throw new MedusaError(
      MedusaError.Types.NOT_FOUND,
      "Collection not found"
    )
  }

  // 2️⃣ Create sale price list
  const { result: saleResult } =
    await createPriceListsWorkflow(req.scope).run({
      input: {
        price_lists_data: [
          {
            title,
            description: `Collection sale`,
            status: "active",
            // type: "sale",
            rules: {
              store_id: [merchant.store_id],
            },
          },
        ],
      },
    })

  const sale = (saleResult as any[])[0]

  // 3️⃣ Get products in collection
  const { rows: products } = await pool.query(
    `
    SELECT product_id
    FROM merchant_collection_products
    WHERE collection_id = $1
    `,
    [collectionId]
  )

  if (products.length === 0) {
    return res.status(201).json({
      sale,
      message: "Sale created but collection has no products",
    })
  }

  const productIds = products.map((p) => p.product_id)

  // 4️⃣ Fetch all variants for those products
  const { data: variants } = await query.graph({
    entity: "product_variant",
    fields: [
      "id",
      "prices.currency_code",
      "prices.amount",
    ],
    filters: {
      product_id: productIds,
    },
  })

  if (!variants || variants.length === 0) {
    return res.status(201).json({
      sale,
      message: "Sale created but no variants found",
    })
  }

  // 5️⃣ Build discounted prices
  const priceData = variants.flatMap((variant: any) =>
    variant.prices.map((price: any) => ({
      variant_id: variant.id,
      currency_code: price.currency_code,
      amount: Math.round(
        price.amount - (price.amount * percentage) / 100
      ),
    }))
  )

  // 6️⃣ Attach discounted prices to sale
  await createPriceListPricesWorkflow(req.scope).run({
    input: {
      data: [
        {
          id: sale.id,
          prices: priceData,
        },
      ],
    },
  })

  res.status(201).json({
    sale,
    variants_discounted: priceData.length,
  })
}
