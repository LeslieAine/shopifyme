import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { deletePromotionsWorkflow } from "@medusajs/medusa/core-flows"

export async function DELETE(
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) {
  const merchantId = req.auth_context.actor_id
  const promotionId = req.params.id

  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated as merchant"
    )
  }

  await deletePromotionsWorkflow(req.scope).run({
    input: {
      ids: [promotionId],
    },
  })

  res.json({
    id: promotionId,
    deleted: true,
  })
}
