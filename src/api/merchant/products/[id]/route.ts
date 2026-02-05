// src/api/merchant/products/[id]/route.ts
import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError, QueryContext } from "@medusajs/framework/utils"
import {
  updateProductsWorkflow,
  updateProductVariantsWorkflow,
} from "@medusajs/medusa/core-flows"

type Body = {
  title?: string
  description?: string
  price?: number
  thumbnail?: string
  images?: { url: string; rank?: number }[]
}

export async function GET(
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) {
  const merchantId = req.auth_context.actor_id
  const productId = req.params.id
  const currency_code =
  req.query.currency_code?.toString() || "usd"

const region_id =
  req.query.region_id?.toString()


  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated"
    )
  }

  const merchantService = req.scope.resolve("merchant")
  const query = req.scope.resolve("query")


  const merchant = await merchantService.retrieveMerchant(merchantId)

  if (!merchant.sales_channel_id) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Merchant has no sales channel"
    )
  }

  /**
   * Ensure product belongs to merchant sales channel
   */
  const { data: links } = await query.graph({
    entity: "product_sales_channel",
    fields: ["product_id"],
    filters: {
      product_id: productId,
      sales_channel_id: merchant.sales_channel_id,
    },
  })

  if (links.length === 0) {
    throw new MedusaError(
      MedusaError.Types.NOT_FOUND,
      "Product not found"
    )
  }

  /**
   * Fetch product with media + variants
   */

  const regionId = req.query.region_id
  const currencyCode = req.query.currency_code

  // const { data: products } = await query.graph({
  //   entity: "product",
  //   fields: [
  //     "*",
  //     "images.*",
  //     "options.*",
  //     "options.values.*",
  //     "variants.*",
  //     'variants.options.*',
  //     "variants.prices.*",
  //     "variants.calculated_price.*"
  //   ],
  //   filters: {
  //     id: productId,
  //   },
  //   context: regionId && currencyCode ? {
  //     variants: {
  //       calculated_price: QueryContext({
  //         region_id: regionId,
  //         currency_code: currencyCode,
  //       }),
  //     },
  //   } : undefined,
  // })

const { data: products } = await query.graph({
  entity: "product",
  fields: [
    "*",
    "images.*",
    "options.*",
    "options.values.*",
    "variants.*",
    "variants.options.*",

    // 👇 THIS is where pricing context lives
    "variants.calculated_price.*",
  ],
  filters: {
    id: productId,
  },
  context: {
      variants: {
        calculated_price: QueryContext({
          currency_code: currencyCode,
          ...(regionId && { region_id: regionId }),
        }),
      },
    },
})



  const product = products[0]

  if (!product) {
    throw new MedusaError(
      MedusaError.Types.NOT_FOUND,
      "Product not found"
    )
  }

  res.json({ product })
}


export async function PATCH(
  req: AuthenticatedMedusaRequest<Body>,
  res: MedusaResponse
) {
  const merchantId = req.auth_context.actor_id
  const productId = req.params.id

  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated"
    )
  }

  const { title, description, price, thumbnail, images } = req.body

  /**
   * 1️⃣ Update product core fields + media
   */
  if (title || description || thumbnail || images) {
    await updateProductsWorkflow(req.scope).run({
      input: {
        products: [
          {
            id: productId,
            ...(title && { title }),
            ...(description && { description }),
            ...(thumbnail && { thumbnail }),
            ...(images && { images }),
          },
        ],
      },
    })
  }

  /**
   * 2️⃣ Update price (single-variant assumption)
   */
  if (price !== undefined) {
    const productService = req.scope.resolve("product")

    const product = await productService.retrieveProduct(productId, {
      relations: ["variants"],
    })

    const variant = product.variants?.[0]

    if (!variant) {
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        "Product has no variants"
      )
    }

    await updateProductVariantsWorkflow(req.scope).run({
      input: {
        product_variants: [
          {
            id: variant.id,
            prices: [
              {
                amount: Math.round(price * 100),
                currency_code: "usd",
              },
            ],
          },
        ],
      },
    })
  }

  res.json({ ok: true })
}
