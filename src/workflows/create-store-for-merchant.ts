import {
  createWorkflow,
  createStep,
  StepResponse,
  WorkflowResponse,
} from "@medusajs/framework/workflows-sdk"
import { MedusaError, Modules } from "@medusajs/framework/utils"

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

    // 1️⃣ Create Store
    const createdStore = await storeService.createStores({
      name: store.name,
    })

    // 2️⃣ Create Sales Channel
    const salesChannel =
      await salesChannelService.createSalesChannels({
        name: `${store.name} Channel`,
        store_ids: [createdStore.id],
      })

    // 3️⃣ Create Shipping Profile (idempotent safe)
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

    // 4️⃣ Update Merchant
    await merchantService.updateMerchants({
      id: merchantId,
      store_id: createdStore.id,
      sales_channel_id: salesChannel.id,
      default_shipping_profile_id: shippingProfile.id,
      status: "pending", // keep pending for admin review
    })

    return new StepResponse({
      store: createdStore,
      sales_channel: salesChannel,
      shipping_profile: shippingProfile,
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
// import {
//   createStockLocationsWorkflow,
//   linkSalesChannelsToStockLocationWorkflow,
//   createServiceZonesWorkflow,
//   createShippingOptionsWorkflow,
// } from "@medusajs/medusa/core-flows"

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
//     const link = container.resolve("link")

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

//     // 3️⃣ Create Shipping Profile
//     // const shippingProfile =
//     //   await fulfillmentService.createShippingProfiles({
//     //     name: `Default - ${merchantId}`,
//     //     type: "default",
//     //   })
//     let shippingProfile

//     try {
//       shippingProfile = await fulfillmentService.createShippingProfiles({
//         name: `Default - ${merchantId}`,
//         type: "default",
//       })
//     } catch (e) {
//       // Profile already exists — fetch it instead
//       const { data } = await container.resolve("query").graph({
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

//     // 4️⃣ Create Stock Location
//     const { result: stockLocations } =
//       await createStockLocationsWorkflow(container).run({
//         input: {
//           locations: [{ name: `${store.name} Warehouse` }],
//         },
//       })

//     const stockLocation = stockLocations[0]

//     // 5️⃣ Link Stock Location → Sales Channel
//     await linkSalesChannelsToStockLocationWorkflow(container).run({
//       input: {
//         id: stockLocation.id,
//         add: [salesChannel.id],
//       },
//     })

//     // 6️⃣ Create Fulfillment Set
//     const fulfillmentSet =
//       await fulfillmentService.createFulfillmentSets({
//         name: `Shipping - ${stockLocation.id}`,
//         type: "shipping",
//         // provider_ids: ["manual_manual"],
//       })

//     await link.create({
//       stock_location: { stock_location_id: stockLocation.id },
//       fulfillment: { fulfillment_set_id: fulfillmentSet.id },
//     })

//     // 🔹 Attach fulfillment provider to stock location
//     await link.create({
//       stock_location: { stock_location_id: stockLocation.id },
//       fulfillment_provider: { fulfillment_provider_id: "manual_manual" },
//     })

//     // 7️⃣ Resolve Regions (safe fallback)
//     let regions: any[] = []

//     let merchantRegions: string[] = []

//     if (merchant.region_ids) {
//       const raw = merchant.region_ids as unknown

//       if (Array.isArray(raw)) {
//         merchantRegions = raw as string[]
//       }
//     }


//     // fallback (temporary safe)
//     if (!regions.length) {
//       const res = await query.graph({
//         entity: "region",
//         fields: ["id", "currency_code", "countries.iso_2"],
//       })

//       regions = res.data.slice(0, 1) // pick first region
//     }

//     // 8️⃣ Geo Zones
//     const geo_zones = regions.flatMap((region) =>
//       region.countries.map((c) => ({
//         type: "country",
//         country_code: c.iso_2,
//       }))
//     )

//     // 9️⃣ Service Zone
//     const { result: serviceZones } =
//       await createServiceZonesWorkflow(container).run({
//         input: {
//           data: [
//             {
//               name: `Zone - ${stockLocation.id}`,
//               fulfillment_set_id: fulfillmentSet.id,
//               geo_zones,
//             },
//           ],
//         },
//       })

//     const serviceZone = serviceZones[0]

//     // 🔟 Prices (multi-currency)
//     const prices = regions.map((r) => ({
//       amount: 0,
//       currency_code: r.currency_code,
//     }))

//     // 1️⃣1️⃣ Shipping Option
//     await createShippingOptionsWorkflow(container).run({
//       input: [
//         {
//           name: "Standard Shipping",
//           service_zone_id: serviceZone.id,
//           shipping_profile_id: shippingProfile.id,
//           provider_id: "manual_manual",
//           type: {
//             label: "Standard",
//             description: "Default shipping",
//             code: "standard",
//           },
//           price_type: "flat",
//           prices,
//         },
//       ],
//     })

//     // 1️⃣2️⃣ Update Merchant
//     await merchantService.updateMerchants({
//       id: merchantId,
//       store_id: createdStore.id,
//       sales_channel_id: salesChannel.id,
//       default_shipping_profile_id: shippingProfile.id,
//       status: "active",
//     })

//     return new StepResponse({
//       store: createdStore,
//       sales_channel: salesChannel,
//       shipping_profile: shippingProfile,
//       stock_location: stockLocation,
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

//     // 3️⃣ Create Default Shipping Profile (Shopify-style)
//     const shippingProfile =
//       await fulfillmentService.createShippingProfiles({
//         name: `Default - ${merchantId}`,
//         type: "default",
//       })

//     // 4️⃣ Update Merchant
//     await merchantService.updateMerchants({
//       id: merchantId,
//       store_id: createdStore.id,
//       sales_channel_id: salesChannel.id,
//       default_shipping_profile_id: shippingProfile.id,
//       status: "active",
//     })

//     return new StepResponse({
//       store: createdStore,
//       sales_channel: salesChannel,
//       shipping_profile: shippingProfile,
//     })
//   }
// )

// const createStoreForMerchantWorkflow = createWorkflow(
//   "create-store-for-merchant",
//   (input: Input) => {
//     const result = createStoreForMerchantStep(input)
//     return new WorkflowResponse(result)
//   }
// )

// export default createStoreForMerchantWorkflow


// // // src/workflows/create-store-for-merchant.ts
// // import {
// //   createWorkflow,
// //   createStep,
// //   StepResponse,
// //   WorkflowResponse,
// // } from "@medusajs/framework/workflows-sdk"
// // import { MedusaError } from "@medusajs/framework/utils"

// // type Input = {
// //   merchantId: string
// //   store: {
// //     name: string
// //   }
// // }

// // const createStoreForMerchantStep = createStep(
// //   "create-store-for-merchant-step",
// //   async ({ merchantId, store }: Input, { container }) => {
// //     const merchantService = container.resolve("merchant")
// //     const storeService = container.resolve("store")
// //     // const salesChannelService = container.resolve("salesChannel") as any
// //     const salesChannelService = container.resolve("sales_channel") as any


// //     const merchant = await merchantService.retrieveMerchant(merchantId)

// //     if (merchant.store_id) {
// //       throw new MedusaError(
// //         MedusaError.Types.INVALID_DATA,
// //         "Merchant already has a store"
// //       )
// //     }

// //     // 1️⃣ create store
// //     const createdStore = await storeService.createStores({
// //       name: store.name,
// //     })

// //     // 2️⃣ create sales channel and attach store
// //     const salesChannel =
// //       await salesChannelService.createSalesChannels({
// //         name: `${store.name} Channel`,
// //         store_ids: [createdStore.id],
// //       })

// //     // 3️⃣ update merchant (ID goes INSIDE data)
// //     await merchantService.updateMerchants({
// //       id: merchantId,
// //       store_id: createdStore.id,
// //       sales_channel_id: salesChannel.id,
// //       status: "active",
// //     })

// //     return new StepResponse({
// //       store: createdStore,
// //       sales_channel: salesChannel,
// //     })
// //   }
// // )

// // const createStoreForMerchantWorkflow = createWorkflow(
// //   "create-store-for-merchant",
// //   (input: Input) => {
// //     const result = createStoreForMerchantStep(input)
// //     return new WorkflowResponse(result)
// //   }
// // )

// // export default createStoreForMerchantWorkflow
