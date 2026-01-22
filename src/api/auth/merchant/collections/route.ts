import { Modules } from "@medusajs/framework/utils"

export const config = {
  auth: {
    actor: "merchant",
  },
}

export async function GET(req, res) {
  const productService = req.scope.resolve(Modules.PRODUCT)

  const collections = await productService.listCollections()

  return res.json({ collections })
}
