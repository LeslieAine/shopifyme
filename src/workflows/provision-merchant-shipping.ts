import {
  createWorkflow,
  WorkflowResponse,
  createStep,
  StepResponse,
} from "@medusajs/framework/workflows-sdk"

import { Modules } from "@medusajs/framework/utils"
import { createServiceZonesWorkflow } from "@medusajs/medusa/core-flows"

type Input = {
  merchantId: string
  stockLocationId: string
  salesChannelId: string
}

const createShippingInfrastructureStep = createStep(
  "create-merchant-shipping-infrastructure",
  async (input: Input, { container }) => {
    const fulfillment = container.resolve(Modules.FULFILLMENT)
    const stockLocationModule = container.resolve(Modules.STOCK_LOCATION)

    /**
     * 1️⃣ Create Shipping Profile
     */
    const shippingProfile = await fulfillment.createShippingProfiles({
      name: `Default - ${input.merchantId}`,
      type: "default",
    })

    /**
     * 2️⃣ Create Fulfillment Set (shipping)
     */
    const [fulfillmentSet] =
      await fulfillment.createFulfillmentSets([
        {
          name: `Shipping - ${input.merchantId}`,
          type: "shipping",
        },
      ])

    /**
     * 3️⃣ Link Fulfillment Set to Stock Location
     */
const link = container.resolve("link")

await link.create({
  [Modules.STOCK_LOCATION]: {
    stock_location_id: input.stockLocationId,
  },
  [Modules.FULFILLMENT]: {
    fulfillment_set_id: fulfillmentSet.id,
  },
})

    /**
     * 4️⃣ Create Service Zone
     */
   const { result: serviceZones } =
  await createServiceZonesWorkflow(container).run({
    input: {
      data: [
        {
          name: `Domestic - ${input.merchantId}`,
          fulfillment_set_id: fulfillmentSet.id,
          geo_zones: [
            {
              type: "country",
              country_code: "us", // you can make this dynamic later
            },
          ],
        },
      ],
    },
  })

const serviceZone = serviceZones[0]


    /**
     * 5️⃣ Create Default Shipping Option
     */
    await fulfillment.createShippingOptions({
      name: "Standard Shipping",
      price_type: "flat",
      service_zone_id: serviceZone.id,
      shipping_profile_id: shippingProfile.id,
      provider_id: "pp_system_default",
      type: {
        label: "Standard",
        description: "Standard Shipping",
        code: "standard",
      },
    })

    return new StepResponse({
      shippingProfileId: shippingProfile.id,
      serviceZoneId: serviceZone.id,
      fulfillmentSetId: fulfillmentSet.id,
    })
  }
)

export const provisionMerchantShippingWorkflow = createWorkflow(
  "provision-merchant-shipping",
  function (input: Input) {
    const infrastructure =
      createShippingInfrastructureStep(input)

    return new WorkflowResponse(infrastructure)
  }
)
