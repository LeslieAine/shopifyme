import type { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { Modules } from "@medusajs/framework/utils"
import { linkProductsToSalesChannelWorkflow } from "@medusajs/medusa/core-flows"

type PublishProductsBody = {
  merchant_id: string
}

export async function POST(
  req: MedusaRequest<PublishProductsBody>,
  res: MedusaResponse
) {
  const { merchant_id } = req.body

  if (!merchant_id) {
    return res.status(400).json({ message: "merchant_id is required" })
  }

  const merchantService = req.scope.resolve("merchant")
  const productService = req.scope.resolve(Modules.PRODUCT)

  const merchant = await merchantService.retrieveMerchant(merchant_id)

  if (!merchant.sales_channel_id) {
    return res
      .status(400)
      .json({ message: "Merchant has no sales channel" })
  }

  const products = await productService.listProducts()

  if (!products.length) {
    return res.json({ message: "No products to publish" })
  }

  await linkProductsToSalesChannelWorkflow(req.scope).run({
    input: {
      id: merchant.sales_channel_id,
      add: products.map((p) => p.id),
    },
  })

  return res.json({
    published: products.length,
    sales_channel_id: merchant.sales_channel_id,
  })
}
