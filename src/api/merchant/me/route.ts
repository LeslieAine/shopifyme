import type {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"

export async function GET(
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) {
  const query = req.scope.resolve("query")
  const merchantId = req.auth_context.actor_id

  const {
    data: [merchant],
  } = await query.graph(
    {
      entity: "merchant",
      fields: ["*"],
      filters: {
        id: merchantId,
      },
    },
    {
      throwIfKeyNotFound: true,
    }
  )

  res.json({ merchant })
}

type UpdateBody = {
  default_shipping_profile_id?: string
}

export async function PATCH(
  req: AuthenticatedMedusaRequest<UpdateBody>,
  res: MedusaResponse
) {
  const merchantService = req.scope.resolve("merchant")
  const merchantId = req.auth_context.actor_id

  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated"
    )
  }

  if (!req.body.default_shipping_profile_id) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "default_shipping_profile_id is required"
    )
  }

  const updated = await merchantService.updateMerchants({
    id: merchantId,
    default_shipping_profile_id:
      req.body.default_shipping_profile_id,
  })

  res.json({ merchant: updated })
}
