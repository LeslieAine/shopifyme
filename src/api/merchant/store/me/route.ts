import type {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { getMerchantStoreId } from "../../../../lib/merchant/get-merchant-store"

export async function GET(
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) {
  const merchantId = req.auth_context.actor_id
  const storeId = await getMerchantStoreId(req.scope, merchantId)

  const query = req.scope.resolve("query")

  const {
    data: [store],
  } = await query.graph(
    {
      entity: "store",
      fields: ["*"],
      filters: {
        id: storeId,
      },
    },
    { throwIfKeyNotFound: true }
  )

  res.json({ store })
}
