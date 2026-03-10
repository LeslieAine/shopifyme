import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { getOrdersListWorkflow } from "@medusajs/medusa/core-flows"
import { MedusaError } from "@medusajs/framework/utils"
import { getMerchantSalesChannelId } from "../../../lib/merchant/get-merchant-sales-channel"

const ORDER_LIST_FIELDS = [
  "id",
  "display_id",
  "status",
  "email",
  "currency_code",
  "sales_channel_id",
  "created_at",
  "updated_at",
]

export async function GET(
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) {
  const merchantId = req.auth_context.actor_id

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

  const limitRaw = Number(req.query.limit ?? 20)
  const offsetRaw = Number(req.query.offset ?? 0)
  const limit = Number.isFinite(limitRaw)
    ? Math.min(Math.max(limitRaw, 1), 100)
    : 20
  const offset = Number.isFinite(offsetRaw)
    ? Math.max(offsetRaw, 0)
    : 0

  const status = req.query.status?.toString()

  const { result } = await getOrdersListWorkflow(req.scope).run({
    input: {
      fields: ORDER_LIST_FIELDS,
      variables: {
        filters: {
          is_draft_order: false,
          sales_channel_id: [salesChannelId],
          ...(status ? { status } : {}),
        },
        skip: offset,
        take: limit,
        order: {
          created_at: "DESC",
        },
      },
    },
  })

  if (Array.isArray(result)) {
    return res.json({
      orders: result,
      count: result.length,
      offset,
      limit,
    })
  }

  res.json({
    orders: result.rows,
    count: result.metadata.count,
    offset: result.metadata.skip,
    limit: result.metadata.take,
  })
}
