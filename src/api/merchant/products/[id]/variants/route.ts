// //src/api/merchant/products/[id]/variants/route.ts
// import {
//   AuthenticatedMedusaRequest,
//   MedusaResponse,
// } from "@medusajs/framework/http"
// import { MedusaError } from "@medusajs/framework/utils"
// import { createProductVariantsWorkflow } from "@medusajs/medusa/core-flows"

// type Body = {
//   variants: {
//     title: string
//     sku?: string
//     options: Record<string, string>
//     price: number
//   }[]
// }

// export async function POST(
//   req: AuthenticatedMedusaRequest<Body>,
//   res: MedusaResponse
// ) {
//   const merchantId = req.auth_context.actor_id
//   const productId = req.params.id
//   const { variants } = req.body

//   if (!merchantId) {
//     throw new MedusaError(
//       MedusaError.Types.UNAUTHORIZED,
//       "Not authenticated as merchant"
//     )
//   }

//   if (!Array.isArray(variants) || variants.length === 0) {
//     throw new MedusaError(
//       MedusaError.Types.INVALID_DATA,
//       "Variants are required"
//     )
//   }

//   const { result } = await createProductVariantsWorkflow(req.scope).run({
//     input: {
//       product_variants: variants.map((v) => ({
//         product_id: productId,
//         title: v.title,
//         sku: v.sku,
//         options: v.options,
//         prices: [
//           {
//             amount: Math.round(v.price * 100),
//             currency_code: "usd",
//           },
//         ],
//       })),
//     },
//   })

//   res.json({ variants: result })
// }

import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { deleteProductVariantsWorkflow } from "@medusajs/medusa/core-flows"

export async function DELETE(
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) {
  const productId = req.params.id
  const query = req.scope.resolve("query")

  // 1️⃣ Load all variants for product
  const { data: variants } = await query.graph({
    entity: "product_variant",
    fields: ["id", "title"],
    filters: { product_id: productId },
  })

  // 2️⃣ Exclude Default variant
  const realVariantIds = variants
    .filter((v) => v.title !== "Default")
    .map((v) => v.id)

  // 3️⃣ Delete if any exist
  if (realVariantIds.length > 0) {
    await deleteProductVariantsWorkflow(req.scope).run({
      input: {
        ids: realVariantIds,
      },
    })
  }

  res.json({
    deleted: realVariantIds.length,
  })
}
