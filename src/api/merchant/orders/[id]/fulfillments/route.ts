import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
  refetchEntity,
} from "@medusajs/framework/http"
import {
  createOrderFulfillmentWorkflow,
  getOrderDetailWorkflow,
} from "@medusajs/medusa/core-flows"
import { MedusaError } from "@medusajs/framework/utils"
import { getMerchantSalesChannelId } from "../../../../../lib/merchant/get-merchant-sales-channel"

type Params = {
  id: string
}

type Body = {
  items: { id: string; quantity: number }[]
  location_id?: string | null
  shipping_option_id?: string
  no_notification?: boolean
  metadata?: Record<string, unknown> | null
}

export async function POST(
  req: AuthenticatedMedusaRequest<Body, Params>,
  res: MedusaResponse
) {
  const merchantId = req.auth_context.actor_id
  const orderId = req.params.id
  const body = req.body

  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated as merchant"
    )
  }

  if (!Array.isArray(body?.items) || body.items.length === 0) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "items are required"
    )
  }

  const salesChannelId = await getMerchantSalesChannelId(
    req.scope,
    merchantId
  )

  const { result: order } = await getOrderDetailWorkflow(req.scope).run({
    input: {
      order_id: orderId,
      fields: ["id", "sales_channel_id", "items.id"],
    },
  })

  if (!order || order.sales_channel_id !== salesChannelId) {
    throw new MedusaError(
      MedusaError.Types.NOT_FOUND,
      "Order not found"
    )
  }

  const validItemIds = new Set((order.items || []).map((i: any) => i.id))
  const invalid = body.items.some(
    (i) =>
      !i?.id ||
      !Number.isFinite(i.quantity) ||
      i.quantity <= 0 ||
      !validItemIds.has(i.id)
  )

  if (invalid) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "One or more items are invalid for this order"
    )
  }

  await createOrderFulfillmentWorkflow(req.scope).run({
    input: {
      ...body,
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
