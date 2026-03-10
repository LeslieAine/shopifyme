import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError, Modules } from "@medusajs/framework/utils"

type Body = {
  name: string
  type?: "default" | "custom"
}

export async function POST(
  req: AuthenticatedMedusaRequest<Body>,
  res: MedusaResponse
) {
  const merchantId = req.auth_context.actor_id

  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated"
    )
  }

  const merchantService = req.scope.resolve("merchant")
  const fulfillmentService = req.scope.resolve(Modules.FULFILLMENT)

  const merchant = await merchantService.retrieveMerchant(merchantId)

  const { name, type = "custom" } = req.body

  if (!name) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Profile name required"
    )
  }

  const profile =
    await fulfillmentService.createShippingProfiles({
      name,
      type,
    })

  return res.status(201).json({ shipping_profile: profile })
}
