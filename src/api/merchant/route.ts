import type {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import createMerchantWorkflow from "../../workflows/create-merchant"

type RequestBody = {
  name: string
  email: string
}

export async function POST(
  req: AuthenticatedMedusaRequest<RequestBody>,
  res: MedusaResponse
) {
  // If actor_id exists, this auth identity is already a merchant
  if (req.auth_context.actor_id) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Request already authenticated as a merchant."
    )
  }

  const { result } = await createMerchantWorkflow(req.scope).run({
    input: {
      merchant: req.body,
      authIdentityId: req.auth_context.auth_identity_id,
    },
  })

  res.status(200).json({ merchant: result })
}
