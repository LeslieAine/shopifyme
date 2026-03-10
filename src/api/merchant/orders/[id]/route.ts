import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { getOrderDetailWorkflow } from "@medusajs/medusa/core-flows"
import { MedusaError } from "@medusajs/framework/utils"
import { getMerchantSalesChannelId } from "../../../../lib/merchant/get-merchant-sales-channel"

type Params = {
  id: string
}

const ORDER_DETAIL_FIELDS = [
  "*",
  "items.*",
  "items.item.*",
  "fulfillments.*",
  "shipping_methods.*",
  "summary.*",
  "transactions.*",
]

export async function GET(
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
      fields: ORDER_DETAIL_FIELDS,
    },
  })

  if (!order || order.sales_channel_id !== salesChannelId) {
    throw new MedusaError(
      MedusaError.Types.NOT_FOUND,
      "Order not found"
    )
  }

  res.json({ order })
}
