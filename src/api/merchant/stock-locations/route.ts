import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import {
  createStockLocationsWorkflow,
  linkSalesChannelsToStockLocationWorkflow,
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

  // 1️⃣ Create stock location
  const { result: stockLocations } =
    await createStockLocationsWorkflow(req.scope).run({
      input: {
        locations: [
          {
            name,
          },
        ],
      },
    })

  const stockLocation = stockLocations[0]

  // 2️⃣ Link stock location to merchant's sales channel
  await linkSalesChannelsToStockLocationWorkflow(req.scope).run({
    input: {
      id: stockLocation.id,
      add: [merchant.sales_channel_id],
    },
  })

  res.status(201).json({ stock_location: stockLocation })
}
