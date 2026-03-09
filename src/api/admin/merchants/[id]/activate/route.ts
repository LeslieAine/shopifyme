import type {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import {
  createStockLocationsWorkflow,
  createLocationFulfillmentSetWorkflow,
  createServiceZonesWorkflow,
  createShippingOptionsWorkflow,
} from "@medusajs/medusa/core-flows"
import { pool } from "../../../../../lib/db"

type Params = {
  id: string
}

function isAlreadyExistsError(error: unknown) {
  const msg = String((error as any)?.message ?? "").toLowerCase()
  return msg.includes("already exists")
}

export async function POST(
  req: AuthenticatedMedusaRequest<unknown, Params>,
  res: MedusaResponse
) {
  const { id } = req.params

  const merchantService = req.scope.resolve("merchant") as any
  const query = req.scope.resolve("query") as any
  const merchant = await merchantService.retrieveMerchant(id)

  if (
    !merchant.warehouse_address_line_1 ||
    !merchant.warehouse_city ||
    !merchant.warehouse_postal_code ||
    !merchant.warehouse_country_code
  ) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Merchant warehouse address is incomplete"
    )
  }

  if (!merchant.store_id || !merchant.sales_channel_id) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Merchant must have store before activation"
    )
  }

  if (!merchant.default_shipping_profile_id) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Merchant missing shipping profile"
    )
  }

  // 1) Resolve/create stock location
  let stockLocationId = merchant.stock_location_id as string | undefined

  if (!stockLocationId) {
    const { result: stockLocations } = await createStockLocationsWorkflow(req.scope).run({
      input: {
        locations: [
          {
            name: `Warehouse - ${merchant.id}`,
            address: {
              address_1: merchant.warehouse_address_line_1,
              city: merchant.warehouse_city,
              postal_code: merchant.warehouse_postal_code,
              country_code: merchant.warehouse_country_code,
              phone: merchant.warehouse_phone ?? undefined,
            },
          },
        ],
      },
    })

    const created = (stockLocations as any[])[0]
    if (!created?.id) {
      throw new MedusaError(
        MedusaError.Types.UNEXPECTED_STATE,
        "Failed to create stock location"
      )
    }

    stockLocationId = created.id

    await merchantService.updateMerchants({
      id: merchant.id,
      stock_location_id: stockLocationId,
    })
  }

  if (!stockLocationId) {
    throw new MedusaError(
      MedusaError.Types.UNEXPECTED_STATE,
      "stockLocationId missing after create/reuse step"
    )
  }

  // 2) Resolve/create fulfillment set by name (do not trust workflow result shape)
  const fulfillmentSetName = `Shipping - ${merchant.id}`

  try {
    await createLocationFulfillmentSetWorkflow(req.scope).run({
      input: {
        location_id: stockLocationId,
        fulfillment_set_data: {
          name: fulfillmentSetName,
          type: "shipping",
        },
      },
    })
  } catch (e) {
    if (!isAlreadyExistsError(e)) {
      throw e
    }
  }

  const fulfillmentSetRow = await pool.query(
    `
      SELECT id
      FROM fulfillment_set
      WHERE name = $1
        AND deleted_at IS NULL
      ORDER BY created_at DESC
      LIMIT 1
    `,
    [fulfillmentSetName]
  )

  if (!fulfillmentSetRow.rows.length) {
    throw new MedusaError(
      MedusaError.Types.UNEXPECTED_STATE,
      `Fulfillment set not found after create/reuse: ${fulfillmentSetName}`
    )
  }

  const fulfillmentSetId = fulfillmentSetRow.rows[0].id as string

  // 3) Reconcile merchant stock location with fulfillment-set linkage
  const lfs = await pool.query(
    `
      SELECT stock_location_id
      FROM location_fulfillment_set
      WHERE fulfillment_set_id = $1
        AND deleted_at IS NULL
      ORDER BY created_at DESC
      LIMIT 1
    `,
    [fulfillmentSetId]
  )

  if (!lfs.rows.length) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      `Fulfillment set ${fulfillmentSetId} is not linked to any stock location`
    )
  }

  const linkedStockLocationId = lfs.rows[0].stock_location_id as string

  if (linkedStockLocationId !== stockLocationId) {
    stockLocationId = linkedStockLocationId

    await merchantService.updateMerchants({
      id: merchant.id,
      stock_location_id: stockLocationId,
    })
  }

  // 4) Ensure provider is enabled on reconciled stock location
  const backendUrl = process.env.MEDUSA_BACKEND_URL ?? "http://localhost:9000"

  const providerRes = await fetch(
    `${backendUrl}/admin/stock-locations/${stockLocationId}/fulfillment-providers`,
    {
      method: "POST",
      headers: {
        Authorization: req.headers.authorization || "",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ add: ["manual_manual"] }),
    }
  )

  if (!providerRes.ok) {
    const body = await providerRes.text()
    const msg = `${providerRes.status} ${body}`.toLowerCase()

    if (!msg.includes("already exists") && !msg.includes("already enabled")) {
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        `Failed enabling provider manual_manual on stock location ${stockLocationId}: ${providerRes.status} ${body}`
      )
    }
  }

  const providerCheck = await pool.query(
    `
      SELECT 1
      FROM location_fulfillment_provider
      WHERE stock_location_id = $1
        AND fulfillment_provider_id = $2
        AND deleted_at IS NULL
      LIMIT 1
    `,
    [stockLocationId, "manual_manual"]
  )

  if (!providerCheck.rows.length) {
    throw new MedusaError(
      MedusaError.Types.NOT_ALLOWED,
      "Providers (manual_manual) are not enabled for the service location"
    )
  }

  // 5) Build geo zones from merchant regions
  const regionIdsRaw = merchant.region_ids as any
  const regionIds = Array.isArray(regionIdsRaw)
    ? regionIdsRaw
    : Array.isArray(regionIdsRaw?.values)
      ? regionIdsRaw.values
      : []

  if (!regionIds.length) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Merchant has no regions configured"
    )
  }

  const { data: regions } = await query.graph({
    entity: "region",
    fields: ["id", "currency_code", "countries.iso_2"],
    filters: { id: regionIds },
  })

  if (!regions?.length) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "No valid regions found for merchant"
    )
  }

  const geoZones = (regions as any[]).flatMap((region: any) =>
    (region.countries || []).map((c: any) => ({
      type: "country",
      country_code: c.iso_2,
    }))
  )

  if (!geoZones.length) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "No geo zones could be derived from merchant regions"
    )
  }

  // 6) Resolve/create service zone by name
  const serviceZoneName = `Zone - ${merchant.id}`

  try {
    await createServiceZonesWorkflow(req.scope).run({
      input: {
        data: [
          {
            name: serviceZoneName,
            fulfillment_set_id: fulfillmentSetId,
            geo_zones: geoZones,
          },
        ],
      },
    })
  } catch (e) {
    if (!isAlreadyExistsError(e)) {
      throw e
    }
  }

  const serviceZoneRow = await pool.query(
    `
      SELECT id, fulfillment_set_id
      FROM service_zone
      WHERE name = $1
        AND deleted_at IS NULL
      ORDER BY created_at DESC
      LIMIT 1
    `,
    [serviceZoneName]
  )

  if (!serviceZoneRow.rows.length) {
    throw new MedusaError(
      MedusaError.Types.UNEXPECTED_STATE,
      `Service zone not found after create/reuse: ${serviceZoneName}`
    )
  }

  const serviceZoneId = serviceZoneRow.rows[0].id as string
  const zoneFulfillmentSetId = serviceZoneRow.rows[0].fulfillment_set_id as string

  if (zoneFulfillmentSetId !== fulfillmentSetId) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Existing service zone is linked to a different fulfillment set"
    )
  }

  // 7) Create shipping option only if missing
  const existingShipping = await pool.query(
    `
      SELECT id
      FROM shipping_option
      WHERE service_zone_id = $1
        AND shipping_profile_id = $2
        AND provider_id = $3
        AND deleted_at IS NULL
      LIMIT 1
    `,
    [serviceZoneId, merchant.default_shipping_profile_id, "manual_manual"]
  )

  if (!existingShipping.rows.length) {
    const prices = (regions as any[]).map((r: any) => ({
      amount: 0,
      currency_code: r.currency_code,
    }))

    try {
      await createShippingOptionsWorkflow(req.scope).run({
        input: [
          {
            name: "Standard Shipping",
            service_zone_id: serviceZoneId,
            shipping_profile_id: merchant.default_shipping_profile_id,
            provider_id: "manual_manual",
            type: {
              label: "Standard",
              description: "Standard shipping",
              code: "standard",
            },
            price_type: "flat",
            prices,
          },
        ],
      })
    } catch (e) {
      if (!isAlreadyExistsError(e)) {
        throw e
      }
    }
  }

  // 8) Activate merchant
  await merchantService.updateMerchants({
    id: merchant.id,
    status: "active",
    stock_location_id: stockLocationId,
  })

  res.json({
    message: "Merchant activated",
  })
}





// import type {
//     AuthenticatedMedusaRequest,
//     MedusaResponse,
// } from "@medusajs/framework/http"

// import { MedusaError } from "@medusajs/framework/utils"

// import {
//     createStockLocationsWorkflow,
//     createLocationFulfillmentSetWorkflow,
//     createServiceZonesWorkflow,
//     createShippingOptionsWorkflow,
// } from "@medusajs/medusa/core-flows"

// type Params = {
//     id: string
// }

// export async function POST(
//     req: AuthenticatedMedusaRequest<unknown, Params>,
//     res: MedusaResponse
// ) {
//     const { id } = req.params

//     const merchantService = req.scope.resolve("merchant")
//     const query = req.scope.resolve("query")

//     const merchant = await merchantService.retrieveMerchant(id)

//     if (
//         !merchant.warehouse_address_line_1 ||
//         !merchant.warehouse_city ||
//         !merchant.warehouse_postal_code ||
//         !merchant.warehouse_country_code
//     ) {
//         throw new MedusaError(
//             MedusaError.Types.INVALID_DATA,
//             "Merchant warehouse address is incomplete"
//         )
//     }

//     if (!merchant.store_id || !merchant.sales_channel_id) {
//         throw new MedusaError(
//             MedusaError.Types.INVALID_DATA,
//             "Merchant must have store before activation"
//         )
//     }

//     if (!merchant.default_shipping_profile_id) {
//         throw new MedusaError(
//             MedusaError.Types.INVALID_DATA,
//             "Merchant missing shipping profile"
//         )
//     }

//     // 1️⃣ Create Stock Location
//     const { result: stockLocations } =
//         await createStockLocationsWorkflow(req.scope).run({
//             input: {
//                 locations: [
//                     {
//                         name: `Warehouse - ${merchant.id}`,
//                         address: {
//                             address_1: merchant.warehouse_address_line_1,
//                             city: merchant.warehouse_city,
//                             postal_code: merchant.warehouse_postal_code,
//                             country_code: merchant.warehouse_country_code,
//                             phone: merchant.warehouse_phone ?? undefined,
//                         },
//                     },
//                 ],
//             },
//         })

//     const stockLocation = stockLocations[0]

//     // 2️⃣ Create + Link Fulfillment Set to Stock Location
//     //     const { result } =
//     //   await createLocationFulfillmentSetWorkflow(req.scope).run({
//     //     input: {
//     //       location_id: stockLocation.id,
//     //       fulfillment_set_data: {
//     //         name: `Shipping - ${merchant.id}`,
//     //         type: "shipping",
//     //       },
//     //     },
//     //   })

//     // const fulfillmentSet = result as { id: string }

//     //     // 3️⃣ Attach Manual Provider to Stock Location (Admin API)
//     //     await fetch(
//     //         `${process.env.MEDUSA_BACKEND_URL}/admin/stock-locations/${stockLocation.id}/fulfillment-providers`,
//     //         {
//     //             method: "POST",
//     //             headers: {
//     //                 Authorization: req.headers.authorization || "",
//     //                 "Content-Type": "application/json",
//     //             },
//     //             body: JSON.stringify({
//     //                 add: ["manual_manual"],
//     //             }),
//     //         }
//     //     )

//     // instead of always creating with fixed name and failing on retries
//     // 2) Create + link fulfillment set to stock location (idempotent)
//     let fulfillmentSetId: string

//     try {
//         const { result } = await createLocationFulfillmentSetWorkflow(req.scope).run({
//             input: {
//                 location_id: stockLocation.id,
//                 fulfillment_set_data: {
//                     name: `Shipping - ${merchant.id}`,
//                     type: "shipping",
//                 },
//             },
//         })

//         fulfillmentSetId = (result as { id: string }).id
//     } catch (e: any) {
//         const msg = String(e?.message ?? "")
//         if (!msg.includes("already exists")) {
//             throw e
//         }

//         const { data } = await query.graph({
//             entity: "fulfillment_set",
//             fields: ["id", "name"],
//             filters: { name: `Shipping - ${merchant.id}` },
//         })

//         if (!data?.length) {
//             throw e
//         }

//         fulfillmentSetId = (data[0] as { id: string }).id
//     }



//     // 4️⃣ Build Geo Zones
//     const regionIds = merchant.region_ids?.values ?? []

//     const { data: regions } = await query.graph({
//         entity: "region",
//         fields: ["id", "currency_code", "countries.iso_2"],
//         filters: {
//             id: regionIds,
//         },
//     })

//     const geo_zones = regions.flatMap((region: any) =>
//         region.countries.map((c: any) => ({
//             type: "country",
//             country_code: c.iso_2,
//         }))
//     )

//     // 5️⃣ Create Service Zone
//     let serviceZoneId: string

//     try {
//         const { result: serviceZones } = await createServiceZonesWorkflow(req.scope).run({
//             input: {
//                 data: [
//                     {
//                         name: `Zone - ${merchant.id}`,
//                         fulfillment_set_id: fulfillmentSetId,
//                         geo_zones,
//                     },
//                 ],
//             },
//         })

//         serviceZoneId = serviceZones[0].id
//     } catch (e: any) {
//         const msg = String(e?.message ?? "")
//         if (!msg.includes("already exists")) throw e

//         const { data } = await query.graph({
//             entity: "service_zone",
//             fields: ["id", "name"],
//             filters: { name: `Zone - ${merchant.id}` },
//         })

//         if (!data?.length) throw e
//         serviceZoneId = (data[0] as { id: string }).id
//     }

//     // const { result: serviceZones } =
//     //     await createServiceZonesWorkflow(req.scope).run({
//     //         input: {
//     //             data: [
//     //                 {
//     //                     name: `Zone - ${merchant.id}`,
//     //                     fulfillment_set_id: fulfillmentSetId,
//     //                     geo_zones,
//     //                 },
//     //             ],
//     //         },
//     //     })

//     // const serviceZone = serviceZones[0]


//     const prices = regions.map((r: any) => ({
//         amount: 0,
//         currency_code: r.currency_code,
//     }))

//     // 6️⃣ Create Shipping Option
//     await createShippingOptionsWorkflow(req.scope).run({
//         input: [
//             {
//                 name: "Standard Shipping",
//                 service_zone_id: serviceZoneId,
//                 shipping_profile_id: merchant.default_shipping_profile_id,
//                 provider_id: "manual_manual",
//                 type: {
//                     label: "Standard",
//                     description: "Standard shipping",
//                     code: "standard",
//                 },
//                 price_type: "flat",
//                 prices,
//             },
//         ],
//     })

//     // 7️⃣ Activate Merchant
//     await merchantService.updateMerchants({
//         id: merchant.id,
//         status: "active",
//     })

//     res.json({
//         message: "Merchant activated",
//     })
// }


// // import type {
// //     AuthenticatedMedusaRequest,
// //     MedusaResponse,
// // } from "@medusajs/framework/http"
// // import { MedusaError, Modules } from "@medusajs/framework/utils"
// // import {
// //     createStockLocationsWorkflow,
// //     createServiceZonesWorkflow,
// //     createShippingOptionsWorkflow,
// // } from "@medusajs/medusa/core-flows"

// // type Params = {
// //     id: string
// // }

// // export async function POST(
// //     req: AuthenticatedMedusaRequest<unknown, Params>,
// //     res: MedusaResponse
// // ) {
// //     const { id } = req.params

// //     const merchantService = req.scope.resolve("merchant")
// //     const fulfillmentService = req.scope.resolve(Modules.FULFILLMENT)
// //     const query = req.scope.resolve("query")
// //     const link = req.scope.resolve("link")

// //     const merchant = await merchantService.retrieveMerchant(id)

// //     if (
// //         !merchant.warehouse_address_line_1 ||
// //         !merchant.warehouse_city ||
// //         !merchant.warehouse_postal_code ||
// //         !merchant.warehouse_country_code
// //     ) {
// //         throw new MedusaError(
// //             MedusaError.Types.INVALID_DATA,
// //             "Merchant warehouse address is incomplete"
// //         )
// //     }

// //     if (!merchant.store_id || !merchant.sales_channel_id) {
// //         throw new MedusaError(
// //             MedusaError.Types.INVALID_DATA,
// //             "Merchant must have store before activation"
// //         )
// //     }

// //     if (!merchant.default_shipping_profile_id) {
// //         throw new MedusaError(
// //             MedusaError.Types.INVALID_DATA,
// //             "Merchant missing shipping profile"
// //         )
// //     }

// //     if (!merchant.warehouse_address_line_1) {
// //         throw new MedusaError(
// //             MedusaError.Types.INVALID_DATA,
// //             "Merchant missing warehouse address"
// //         )
// //     }

// //     // 1️⃣ Create Stock Location
// //     const { result: stockLocations } =
// //         await createStockLocationsWorkflow(req.scope).run({
// //             input: {
// //                 locations: [
// //                     {
// //                         name: `Warehouse - ${merchant.id}`,
// //                         address: {
// //                             address_1: merchant.warehouse_address_line_1,
// //                             city: merchant.warehouse_city,
// //                             postal_code: merchant.warehouse_postal_code,
// //                             country_code: merchant.warehouse_country_code,
// //                             phone: merchant.warehouse_phone,
// //                         },
// //                     },
// //                 ],
// //             },
// //         })

// //     const stockLocation = stockLocations[0]

// //     // 2️⃣ Create Fulfillment Set
// //     // const fulfillmentSet =
// //     //     await fulfillmentService.createFulfillmentSets({
// //     //         name: `Shipping - ${merchant.id}`,
// //     //         type: "shipping",
// //     //         provider_ids: ["manual_manual"],
// //     //     })

// //     // 3️⃣ Link Fulfillment Set ↔ Stock Location
// //     // await link.create({
// //     //     stock_location: { stock_location_id: stockLocation.id },
// //     //     fulfillment: { fulfillment_set_id: fulfillmentSet.id },
// //     // })

// //     // 4️⃣ Enable Manual Provider
// //     //   await fulfillmentService.createStockLocationFulfillmentProviders({
// //     //     stock_location_id: stockLocation.id,
// //     //     fulfillment_provider_id: "manual_manual",
// //     //   })
// //     // await link.create({
// //     //     stock_location: { stock_location_id: stockLocation.id },
// //     //     fulfillment_provider: { fulfillment_provider_id: "manual_manual" },
// //     // })
// //     // 5️⃣ Build Geo Zones from merchant.region_ids
// //     const regionIds =
// //         merchant.region_ids?.values ?? []

// //     const { data: regions } = await query.graph({
// //         entity: "region",
// //         fields: ["id", "currency_code", "countries.iso_2"],
// //         filters: {
// //             id: regionIds,
// //         },
// //     })

// //     const geo_zones = regions.flatMap((region: any) =>
// //         region.countries.map((c: any) => ({
// //             type: "country",
// //             country_code: c.iso_2,
// //         }))
// //     )

// //     // 6️⃣ Create Service Zone
// //     const { result: serviceZones } =
// //         await createServiceZonesWorkflow(req.scope).run({
// //             input: {
// //                 data: [
// //                     {
// //                         name: `Zone - ${merchant.id}`,
// //                         fulfillment_set_id: fulfillmentSet.id,
// //                         geo_zones,
// //                     },
// //                 ],
// //             },
// //         })

// //     const serviceZone = serviceZones[0]

// //     const prices = regions.map((r: any) => ({
// //         amount: 0,
// //         currency_code: r.currency_code,
// //     }))

// //     // 7️⃣ Create Shipping Option
// //     await createShippingOptionsWorkflow(req.scope).run({
// //         input: [
// //             {
// //                 name: "Standard Shipping",
// //                 service_zone_id: serviceZone.id,
// //                 shipping_profile_id: merchant.default_shipping_profile_id,
// //                 provider_id: "manual_manual",
// //                 type: {
// //                     label: "Standard",
// //                     description: "Standard shipping",
// //                     code: "standard",
// //                 },
// //                 price_type: "flat",
// //                 prices,
// //             },
// //         ],
// //     })

// //     // 8️⃣ Activate Merchant
// //     await merchantService.updateMerchants({
// //         id: merchant.id,
// //         status: "active",
// //     })

// //     res.json({
// //         message: "Merchant activated",
// //     })
// // }