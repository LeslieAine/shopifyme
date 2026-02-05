// src/api/merchant/products/[id]/variants/route.ts
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
