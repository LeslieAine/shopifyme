import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
  refetchEntity,
} from "@medusajs/framework/http"
import {
  cancelOrderWorkflow,
  getOrderDetailWorkflow,
} from "@medusajs/medusa/core-flows"
import { MedusaError } from "@medusajs/framework/utils"
import { getMerchantSalesChannelId } from "../../../../../lib/merchant/get-merchant-sales-channel"

type Params = {
  id: string
}

export async function POST(
  req: AuthenticatedMedusaRequest<unknown, Params>,
  res: MedusaResponse
) {
  const merchantId = req.auth_context.actor_id
  const orderId = req.params.id

  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated as merchant"
    )
  }

  const salesChannelId = await getMerchantSalesChannelId(
    req.scope,
    merchantId
  )

  const { result: order } = await getOrderDetailWorkflow(req.scope).run({
    input: {
      order_id: orderId,
      fields: ["id", "sales_channel_id"],
    },
  })

  if (!order || order.sales_channel_id !== salesChannelId) {
    throw new MedusaError(
      MedusaError.Types.NOT_FOUND,
      "Order not found"
    )
  }

  await cancelOrderWorkflow(req.scope).run({
    input: {
      order_id: orderId,
    },
  })

  const refreshed = await refetchEntity({
    scope: req.scope,
    entity: "order",
    idOrFilter: orderId,
    fields: ["*", "items.*", "fulfillments.*"],
  })

  res.status(200).json({ order: refreshed })
}
