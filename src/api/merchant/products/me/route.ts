import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"

// export const config = {
//   auth: {
//     actor: "merchant",
//   },
// }


export async function GET(
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) {
  const merchantService = req.scope.resolve("merchant")
  const query = req.scope.resolve("query")

  const merchantId = req.auth_context.actor_id
  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated as merchant"
    )
  }

  const merchant = await merchantService.retrieveMerchant(merchantId)

  if (!merchant.sales_channel_id) {
    return res.json({ products: [] })
  }

  /**
   * 1️⃣ Get product IDs linked to this merchant's sales channel
   */
  const { data: links } = await query.graph({
    entity: "product_sales_channel",
    fields: ["product_id"],
    filters: {
      sales_channel_id: merchant.sales_channel_id,
    },
  })

  const productIds = links.map((l) => l.product_id)

  if (productIds.length === 0) {
    return res.json({ products: [] })
  }

  /**
   * 2️⃣ Fetch products by ID
   */
  const { data: products } = await query.graph({
    entity: "product",
    fields: ["*",
      "images.*",
      "variants.*",
      "variants.prices.*",
    ],
    filters: {
      id: productIds
    },
  })

  res.json({ products })
}
