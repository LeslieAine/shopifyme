// import { MedusaRequest, MedusaResponse } from "@medusajs/framework"
// import { MERCHANT_MODULE } from "../../../modules/merchant"
// import { createMerchantSalesChannelWorkflow } from "../../../workflows/create-merchant-sales-channel"

// type Body = {
//   merchant_id: string
// }

// export async function POST(
//   req: MedusaRequest,
//   res: MedusaResponse
// ) {
//   const { merchant_id } = req.body as Body

//   if (!merchant_id) {
//     res.status(400).json({ message: "merchant_id is required" })
//     return
//   }

//   const merchantService = req.scope.resolve(MERCHANT_MODULE)

//   const merchant = await merchantService.retrieveMerchant(
//     merchant_id
//   )

//   if (!merchant) {
//     res.status(404).json({ message: "Merchant not found" })
//     return
//   }

//   if (!merchant.store_id) {
//     res
//       .status(400)
//       .json({ message: "Merchant has no store" })
//     return
//   }

//   // Idempotency guard
//   if (merchant.sales_channel_id) {
//     res.json({
//       sales_channel_id: merchant.sales_channel_id,
//     })
//     return
//   }

//   const { result } =
//     await createMerchantSalesChannelWorkflow(
//       req.scope
//     ).run({
//       input: {
//         merchant_id,
//         merchant_email: merchant.email,
//         store_id: merchant.store_id,
//       },
//     })

//   await merchantService.updateMerchants({
//     id: merchant_id,
//     sales_channel_id: result.sales_channel_id,
//   })

//   res.json({
//     merchant_id,
//     store_id: merchant.store_id,
//     sales_channel_id: result.sales_channel_id,
//   })
// }


import { MedusaRequest, MedusaResponse } from "@medusajs/framework"
import { Modules } from "@medusajs/framework/utils"
import { MERCHANT_MODULE } from "../../../modules/merchant"

type Body = {
  merchant_id: string
}

export async function POST(
  req: MedusaRequest,
  res: MedusaResponse
) {
  const { merchant_id } = req.body as Body

  if (!merchant_id) {
    return res.status(400).json({ message: "merchant_id is required" })
  }

  const merchantService = req.scope.resolve(MERCHANT_MODULE)
  const salesChannelService = req.scope.resolve(Modules.SALES_CHANNEL)

  const merchant = await merchantService.retrieveMerchant(merchant_id)

  if (!merchant) {
    return res.status(404).json({ message: "Merchant not found" })
  }

  // Idempotency
  if (merchant.sales_channel_id) {
    return res.json({
      sales_channel_id: merchant.sales_channel_id,
    })
  }

  const [salesChannel] =
    await salesChannelService.createSalesChannels([
      {
        name: `${merchant.email} Channel`,
        description: `Sales channel for ${merchant.email}`,
      },
    ])

  await merchantService.updateMerchants({
    id: merchant_id,
    sales_channel_id: salesChannel.id,
  })

  res.json({
    merchant_id,
    sales_channel_id: salesChannel.id,
  })
}
