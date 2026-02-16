// src/api/merchant/promotions/[id]/route.ts
import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { deletePromotionsWorkflow, updatePromotionsWorkflow } from "@medusajs/medusa/core-flows"

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

type UpdateBody = {
  status?: "draft" | "active" | "inactive"
}

export async function PATCH(
  req: AuthenticatedMedusaRequest<UpdateBody>,
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

  const { result } = await updatePromotionsWorkflow(req.scope).run({
    input: {
      promotionsData: [
        {
          id: promotionId,
          status: req.body.status,
        },
      ],
    },
  })

  res.json({
    promotion: result[0],
  })
}


