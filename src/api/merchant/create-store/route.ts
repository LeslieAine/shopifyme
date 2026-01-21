import { MedusaRequest, MedusaResponse } from "@medusajs/framework"
import { MERCHANT_MODULE } from "../../../modules/merchant"
import { Modules } from "@medusajs/framework/utils"

type CreateStoreBody = {
  merchant_id: string
}

export async function POST(
  req: MedusaRequest,
  res: MedusaResponse
) {
  const { merchant_id } = req.body as CreateStoreBody

  if (!merchant_id) {
    res.status(400).json({ message: "merchant_id is required" })
    return
  }

  const merchantService = req.scope.resolve(MERCHANT_MODULE)
  const storeService = req.scope.resolve(Modules.STORE)

  const merchant = await merchantService.retrieveMerchant(merchant_id)

  if (!merchant) {
    res.status(404).json({ message: "Merchant not found" })
    return
  }

  // Idempotency guard
  if (merchant.store_id) {
    res.json({ store_id: merchant.store_id })
    return
  }

  const store = await storeService.createStores({
    name: `${merchant.email}'s Store`,
  })

  await merchantService.updateMerchants({
    id: merchant_id,
    store_id: store.id,
    status: "active",
  })

  res.json({
    merchant_id,
    store_id: store.id,
  })
}
