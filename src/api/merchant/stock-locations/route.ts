// src/api/merchant/stock-locations/route.ts
import {
    AuthenticatedMedusaRequest,
    MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError, Modules } from "@medusajs/framework/utils"
import {
    createStockLocationsWorkflow,
    linkSalesChannelsToStockLocationWorkflow,
    createServiceZonesWorkflow,
    createShippingOptionsWorkflow,
} from "@medusajs/medusa/core-flows"

type Body = {
    name: string
}

export async function POST(
    req: AuthenticatedMedusaRequest<Body>,
    res: MedusaResponse
) {
    const merchantId = req.auth_context.actor_id

    if (!merchantId) {
        throw new MedusaError(
            MedusaError.Types.UNAUTHORIZED,
            "Not authenticated as merchant"
        )
    }

    const merchantService = req.scope.resolve("merchant")
    const merchant = await merchantService.retrieveMerchant(merchantId)

    if (!merchant.sales_channel_id) {
        throw new MedusaError(
            MedusaError.Types.INVALID_DATA,
            "Merchant has no sales channel"
        )
    }

    const { name } = req.body

    if (!name) {
        throw new MedusaError(
            MedusaError.Types.INVALID_DATA,
            "Warehouse name is required"
        )
    }

    // ----------------------------
    // 1️⃣ Create stock location
    // ----------------------------
    const { result: stockLocations } =
        await createStockLocationsWorkflow(req.scope).run({
            input: {
                locations: [{ name }],
            },
        })

    const stockLocation = stockLocations[0]

    // ----------------------------
    // 2️⃣ Link to sales channel
    // ----------------------------
    await linkSalesChannelsToStockLocationWorkflow(req.scope).run({
        input: {
            id: stockLocation.id,
            add: [merchant.sales_channel_id],
        },
    })

    // ============================
    // 🔥 SHIPPING PROVISIONING
    // ============================

    const container = req.scope
    const fulfillmentService = container.resolve(Modules.FULFILLMENT)
    const query = container.resolve("query")
    const link = container.resolve("link")

    // Ensure merchant has regions
    //   if (!merchant.region_ids || merchant.region_ids.length === 0) {
    //     throw new MedusaError(
    //       MedusaError.Types.INVALID_DATA,
    //       "Merchant has no regions configured"
    //     )
    //   }
    const merchantRegions = merchant.region_ids?.values as string[] | undefined

    if (!merchantRegions || merchantRegions.length === 0) {
        throw new MedusaError(
            MedusaError.Types.INVALID_DATA,
            "Merchant has no regions configured"
        )
    }


    // ----------------------------
    // 3️⃣ Ensure Shipping Profile
    // ----------------------------
    let shippingProfileId = merchant.default_shipping_profile_id

    if (!shippingProfileId) {
        const shippingProfile =
            await fulfillmentService.createShippingProfiles({
                name: `Default - ${merchant.id}`,
                type: "default",
            })

        shippingProfileId = shippingProfile.id

        await merchantService.updateMerchants({
            id: merchant.id,
            default_shipping_profile_id: shippingProfileId,
        })
    }

    // ----------------------------
    // 4️⃣ Create Fulfillment Set
    // ----------------------------
    const fulfillmentSet =
        await fulfillmentService.createFulfillmentSets({
            name: `Shipping - ${stockLocation.id}`,
            type: "shipping",
        })

    await link.create({
        stock_location: { stock_location_id: stockLocation.id },
        fulfillment: { fulfillment_set_id: fulfillmentSet.id },
    })

    // ----------------------------
    // 5️⃣ Fetch Regions
    // ----------------------------

    if (!merchantRegions || merchantRegions.length === 0) {
        throw new MedusaError(
            MedusaError.Types.INVALID_DATA,
            "Merchant has no regions configured"
        )
    }

    const { data: regions } = await query.graph({
        entity: "region",
        fields: ["id", "currency_code", "countries.iso_2"],
        filters: {
            id: merchantRegions,
        },
    })

    // const { data: regions } = await query.graph({
    //     entity: "region",
    //     fields: ["id", "currency_code", "countries.iso_2"],
    //     filters: { id: merchant.region_ids },
    // })

    // ----------------------------
    // 6️⃣ Build Geo Zones
    // ----------------------------
    const geo_zones = regions.flatMap((region: any) =>
        region.countries.map((country: any) => ({
            type: "country",
            country_code: country.iso_2,
        }))
    )

    // ----------------------------
    // 7️⃣ Create Service Zone
    // ----------------------------
    const { result: serviceZones } =
        await createServiceZonesWorkflow(container).run({
            input: {
                data: [
                    {
                        name: `Zone - ${stockLocation.id}`,
                        fulfillment_set_id: fulfillmentSet.id,
                        geo_zones,
                    },
                ],
            },
        })

    const serviceZone = serviceZones[0]

    // ----------------------------
    // 8️⃣ Build Multi-Currency Prices
    // ----------------------------
    const prices = regions.map((region: any) => ({
        amount: 0,
        currency_code: region.currency_code,
    }))

    // ----------------------------
    // 9️⃣ Create Shipping Option
    // ----------------------------
    await createShippingOptionsWorkflow(container).run({
        input: [
            {
                name: "Standard Shipping",
                service_zone_id: serviceZone.id,
                shipping_profile_id: shippingProfileId,
                provider_id: "pp_system_default",
                type: {
                    label: "Standard",
                    description: "Standard Shipping",
                    code: "standard",
                },
                price_type: "flat",
                prices,
            },
        ],
    })

    // ============================

    res.status(201).json({ stock_location: stockLocation })
}
