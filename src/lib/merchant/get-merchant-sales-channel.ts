import { MedusaError } from "@medusajs/framework/utils"

export async function getMerchantSalesChannelId(
  scope: any,
  merchantId: string
): Promise<string> {
  const merchantService = scope.resolve("merchant")

  const merchant = await merchantService.retrieveMerchant(merchantId)

  if (!merchant.sales_channel_id) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Merchant does not have a sales channel"
    )
  }

  return merchant.sales_channel_id
}
