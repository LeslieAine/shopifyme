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
  percentage: number
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

  if (!merchant.store_id || !merchant.sales_channel_id) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Merchant not properly configured"
    )
  }

  const regionId = req.params.id
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

  // 1️⃣ Verify region exists
  const { data: regionData } = await query.graph({
    entity: "region",
    fields: ["id", "currency_code"],
    filters: { id: regionId },
  })

  const region = regionData?.[0]

  if (!region) {
    throw new MedusaError(
      MedusaError.Types.NOT_FOUND,
      "Region not found"
    )
  }

  // 2️⃣ Create region-scoped sale
  const { result } =
    await createPriceListsWorkflow(req.scope).run({
      input: {
        price_lists_data: [
          {
            title,
            description: "Region-wide sale",
            status: "active",
            rules: {
              store_id: [merchant.store_id],
              region_id: [regionId],
            },
          },
        ],
      },
    })

  const sale = (result as any[])[0]

  // 3️⃣ Fetch merchant product IDs
  const { rows } = await pool.query(
    `
    SELECT product_id
    FROM product_sales_channel
    WHERE sales_channel_id = $1
      AND deleted_at IS NULL
    `,
    [merchant.sales_channel_id]
  )

  if (rows.length === 0) {
    return res.status(201).json({
      sale,
      message: "Sale created but no products found",
    })
  }

  const productIds = rows.map((r) => r.product_id)

  // 4️⃣ Fetch variants
  const { data: variants } = await query.graph({
    entity: "product_variant",
    fields: ["id", "prices.currency_code", "prices.amount"],
    filters: {
      product_id: productIds,
    },
  })

  if (!variants?.length) {
    return res.status(201).json({
      sale,
      message: "Sale created but no variants found",
    })
  }

  // 5️⃣ Build discounted prices
  const priceData = variants.flatMap((variant: any) =>
    variant.prices
      .filter((p: any) => p.currency_code === region.currency_code)
      .map((price: any) => ({
        variant_id: variant.id,
        currency_code: price.currency_code,
        amount: Math.round(
          price.amount - (price.amount * percentage) / 100
        ),
      }))
  )

  if (!priceData.length) {
    return res.status(201).json({
      sale,
      message: "Sale created but no matching region prices found",
    })
  }

  // 6️⃣ Attach prices
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
