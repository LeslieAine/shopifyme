import { batchLinkProductsToCollectionWorkflow } from "@medusajs/medusa/core-flows"

export const config = {
  auth: {
    actor: "merchant",
  },
}

export async function POST(req, res) {
  const { collection_id } = req.params
  const { product_id } = req.body

  if (!product_id) {
    return res.status(400).json({
      message: "product_id is required",
    })
  }

  await batchLinkProductsToCollectionWorkflow(req.scope).run({
    input: {
      id: collection_id,
      add: [product_id],
    },
  })

  return res.json({ success: true })
}
