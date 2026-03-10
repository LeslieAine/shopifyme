import {
  createWorkflow,
  createStep,
  StepResponse,
  WorkflowResponse,
} from "@medusajs/framework/workflows-sdk"
import { MedusaError, Modules } from "@medusajs/framework/utils"
import { createApiKeysWorkflow } from "@medusajs/medusa/core-flows"

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
    const salesChannelService = container.resolve("sales_channel") as any
    const fulfillmentService = container.resolve(Modules.FULFILLMENT)
    const query = container.resolve("query")

    const merchant = await merchantService.retrieveMerchant(merchantId)

    if (merchant.store_id) {
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        "Merchant already has a store"
      )
    }

    // 1) Create Store
    const createdStore = await storeService.createStores({
      name: store.name,
    })

    // 2) Create Sales Channel
    const salesChannel = await salesChannelService.createSalesChannels({
      name: `${store.name} Channel`,
      store_ids: [createdStore.id],
    })

    // 3) Ensure merchant publishable API key exists (created here, linked at activation)
    const keyTitle = `Merchant ${merchantId} Storefront Key`

    const { data: existingKeys } = await query.graph({
      entity: "api_key",
      fields: ["id", "token", "title", "type", "revoked_at"],
      filters: {
        title: keyTitle,
        type: "publishable",
      },
    })

    let publishableKey = (existingKeys || []).find((k: any) => !k.revoked_at)

    if (!publishableKey) {
      const {
        result: [createdKey],
      } = await createApiKeysWorkflow(container).run({
        input: {
          api_keys: [
            {
              title: keyTitle,
              type: "publishable",
              created_by: "",
            },
          ],
        },
      })

      publishableKey = createdKey as any
    }

    // 4) Create Shipping Profile (idempotent safe)
    let shippingProfile

    try {
      shippingProfile = await fulfillmentService.createShippingProfiles({
        name: `Default - ${merchantId}`,
        type: "default",
      })
    } catch (e) {
      const { data } = await query.graph({
        entity: "shipping_profile",
        fields: ["id", "name"],
        filters: {
          name: `Default - ${merchantId}`,
        },
      })

      if (!data?.length) {
        throw e
      }

      shippingProfile = data[0]
    }

    // 5) Update Merchant
    await merchantService.updateMerchants({
      id: merchantId,
      store_id: createdStore.id,
      sales_channel_id: salesChannel.id,
      default_shipping_profile_id: shippingProfile.id,
      status: "pending",
    })

    return new StepResponse({
      store: createdStore,
      sales_channel: salesChannel,
      shipping_profile: shippingProfile,
      publishable_api_key: publishableKey
        ? {
            id: publishableKey.id,
            token: publishableKey.token,
            title: publishableKey.title,
          }
        : null,
    })
  }
)

export default createWorkflow(
  "create-store-for-merchant",
  (input: Input) => {
    const result = createStoreForMerchantStep(input)
    return new WorkflowResponse(result)
  }
)



// import {
//   createWorkflow,
//   createStep,
//   StepResponse,
//   WorkflowResponse,
// } from "@medusajs/framework/workflows-sdk"
// import { MedusaError, Modules } from "@medusajs/framework/utils"

// type Input = {
//   merchantId: string
//   store: {
//     name: string
//   }
// }

// const createStoreForMerchantStep = createStep(
//   "create-store-for-merchant-step",
//   async ({ merchantId, store }: Input, { container }) => {
//     const merchantService = container.resolve("merchant")
//     const storeService = container.resolve("store")
//     const salesChannelService = container.resolve("sales_channel") as any
//     const fulfillmentService = container.resolve(Modules.FULFILLMENT)
//     const query = container.resolve("query")

//     const merchant = await merchantService.retrieveMerchant(merchantId)

//     if (merchant.store_id) {
//       throw new MedusaError(
//         MedusaError.Types.INVALID_DATA,
//         "Merchant already has a store"
//       )
//     }

//     // 1️⃣ Create Store
//     const createdStore = await storeService.createStores({
//       name: store.name,
//     })

//     // 2️⃣ Create Sales Channel
//     const salesChannel =
//       await salesChannelService.createSalesChannels({
//         name: `${store.name} Channel`,
//         store_ids: [createdStore.id],
//       })

//     // 3️⃣ Create Shipping Profile (idempotent safe)
//     let shippingProfile

//     try {
//       shippingProfile = await fulfillmentService.createShippingProfiles({
//         name: `Default - ${merchantId}`,
//         type: "default",
//       })
//     } catch (e) {
//       const { data } = await query.graph({
//         entity: "shipping_profile",
//         fields: ["id", "name"],
//         filters: {
//           name: `Default - ${merchantId}`,
//         },
//       })

//       if (!data?.length) {
//         throw e
//       }

//       shippingProfile = data[0]
//     }

//     // 4️⃣ Update Merchant
//     await merchantService.updateMerchants({
//       id: merchantId,
//       store_id: createdStore.id,
//       sales_channel_id: salesChannel.id,
//       default_shipping_profile_id: shippingProfile.id,
//       status: "pending", // keep pending for admin review
//     })

//     return new StepResponse({
//       store: createdStore,
//       sales_channel: salesChannel,
//       shipping_profile: shippingProfile,
//     })
//   }
// )

// export default createWorkflow(
//   "create-store-for-merchant",
//   (input: Input) => {
//     const result = createStoreForMerchantStep(input)
//     return new WorkflowResponse(result)
//   }
// )
