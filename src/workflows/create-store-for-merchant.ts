import {
  createWorkflow,
  createStep,
  StepResponse,
  WorkflowResponse,
} from "@medusajs/framework/workflows-sdk"
import { MedusaError } from "@medusajs/framework/utils"

type Input = {
  merchantId: string
  store: {
    name: string
  }
}

const createStoreForMerchantStep = createStep(
  "create-store-for-merchant-step",
  async ({ merchantId, store }: Input, { container }) => {
    const merchantService = container.resolve("merchant")
    const storeService = container.resolve("store")
    // const salesChannelService = container.resolve("salesChannel") as any
    const salesChannelService = container.resolve("sales_channel") as any


    const merchant = await merchantService.retrieveMerchant(merchantId)

    if (merchant.store_id) {
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        "Merchant already has a store"
      )
    }

    // 1️⃣ create store
    const createdStore = await storeService.createStores({
      name: store.name,
    })

    // 2️⃣ create sales channel and attach store
    const salesChannel =
      await salesChannelService.createSalesChannels({
        name: `${store.name} Channel`,
        store_ids: [createdStore.id],
      })

    // 3️⃣ update merchant (ID goes INSIDE data)
    await merchantService.updateMerchants({
      id: merchantId,
      store_id: createdStore.id,
      sales_channel_id: salesChannel.id,
      status: "active",
    })

    return new StepResponse({
      store: createdStore,
      sales_channel: salesChannel,
    })
  }
)

const createStoreForMerchantWorkflow = createWorkflow(
  "create-store-for-merchant",
  (input: Input) => {
    const result = createStoreForMerchantStep(input)
    return new WorkflowResponse(result)
  }
)

export default createStoreForMerchantWorkflow
