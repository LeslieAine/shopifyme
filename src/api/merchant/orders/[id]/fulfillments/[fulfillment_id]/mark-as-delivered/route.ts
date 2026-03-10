import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import {
  capturePaymentWorkflow,
  getOrderDetailWorkflow,
  markOrderFulfillmentAsDeliveredWorkflow,
} from "@medusajs/medusa/core-flows"
import { MedusaError } from "@medusajs/framework/utils"
import { getMerchantSalesChannelId } from "../../../../../../../lib/merchant/get-merchant-sales-channel"

type Params = {
  id: string
  fulfillment_id: string
}

export async function POST(
  req: AuthenticatedMedusaRequest<unknown, Params>,
  res: MedusaResponse
) {
  const merchantId = req.auth_context.actor_id
  const orderId = req.params.id
  const fulfillmentId = req.params.fulfillment_id

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
      fields: [
        "id",
        "sales_channel_id",
        "fulfillments.id",
      ],
    },
  })

  if (!order || order.sales_channel_id !== salesChannelId) {
    throw new MedusaError(
      MedusaError.Types.NOT_FOUND,
      "Order not found"
    )
  }

  const hasFulfillment = (order.fulfillments || []).some(
    (f: any) => f.id === fulfillmentId
  )

  if (!hasFulfillment) {
    throw new MedusaError(
      MedusaError.Types.NOT_FOUND,
      "Fulfillment not found on order"
    )
  }

  try {
    await markOrderFulfillmentAsDeliveredWorkflow(req.scope).run({
      input: { orderId, fulfillmentId },
    })
  } catch (e: any) {
    const msg = String(e?.message ?? "")
    if (!msg.includes("already been marked delivered")) {
      throw e
    }
  }

  const { result: deliveredOrder } = await getOrderDetailWorkflow(req.scope).run({
    input: {
      order_id: orderId,
      fields: [
        "id",
        "payment_collections.id",
        "payment_collections.status",
        "payment_collections.payments.id",
        "payment_collections.payments.amount",
        "payment_collections.payments.captured_amount",
      ],
    },
  })

  const toCapture = (deliveredOrder.payment_collections || []).filter(
    (pc: any) => pc.status === "authorized"
  )

  for (const pc of toCapture) {
    for (const payment of pc.payments || []) {
      const captured = Number(payment.captured_amount || 0)
      const total = Number(payment.amount || 0)

      if (captured >= total) {
        continue
      }

      await capturePaymentWorkflow(req.scope).run({
        input: {
          payment_id: payment.id,
          captured_by: merchantId,
        },
      })
    }
  }

  const { result: refreshed } = await getOrderDetailWorkflow(req.scope).run({
    input: {
      order_id: orderId,
      fields: [
        "*",
        "items.*",
        "items.detail.*",
        "fulfillments.*",
        "payment_collections.*",
        "payment_collections.payments.*",
        "transactions.*",
        "summary.*",
      ],
    },
  })

  res.status(200).json({ order: refreshed })
}



// import {
//   AuthenticatedMedusaRequest,
//   MedusaResponse,
//   refetchEntity,
// } from "@medusajs/framework/http"
// import {
//   getOrderDetailWorkflow,
//   markOrderFulfillmentAsDeliveredWorkflow,
// } from "@medusajs/medusa/core-flows"
// import { MedusaError } from "@medusajs/framework/utils"
// import { getMerchantSalesChannelId } from "../../../../../../../lib/merchant/get-merchant-sales-channel"

// type Params = {
//   id: string
//   fulfillment_id: string
// }

// export async function POST(
//   req: AuthenticatedMedusaRequest<unknown, Params>,
//   res: MedusaResponse
// ) {
//   const merchantId = req.auth_context.actor_id
//   const orderId = req.params.id
//   const fulfillmentId = req.params.fulfillment_id

//   if (!merchantId) {
//     throw new MedusaError(
//       MedusaError.Types.UNAUTHORIZED,
//       "Not authenticated as merchant"
//     )
//   }

//   const salesChannelId = await getMerchantSalesChannelId(
//     req.scope,
//     merchantId
//   )

//   const { result: order } = await getOrderDetailWorkflow(req.scope).run({
//     input: {
//       order_id: orderId,
//       fields: ["id", "sales_channel_id", "fulfillments.id"],
//     },
//   })

//   if (!order || order.sales_channel_id !== salesChannelId) {
//     throw new MedusaError(
//       MedusaError.Types.NOT_FOUND,
//       "Order not found"
//     )
//   }

//   const hasFulfillment = (order.fulfillments || []).some(
//     (f: any) => f.id === fulfillmentId
//   )

//   if (!hasFulfillment) {
//     throw new MedusaError(
//       MedusaError.Types.NOT_FOUND,
//       "Fulfillment not found on order"
//     )
//   }

//   await markOrderFulfillmentAsDeliveredWorkflow(req.scope).run({
//     input: {
//       orderId,
//       fulfillmentId,
//     },
//   })

//   const refreshed = await refetchEntity({
//     scope: req.scope,
//     entity: "order",
//     idOrFilter: orderId,
//     fields: ["*", "items.*", "fulfillments.*"],
//   })

//   res.status(200).json({ order: refreshed })
// }
