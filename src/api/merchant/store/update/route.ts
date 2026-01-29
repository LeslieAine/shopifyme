//src/api/merchant/store/update/route.ts
import type {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { getMerchantStoreId } from "../../../../lib/merchant/get-merchant-store"

type Body = {
  name: string
}

export async function POST(
  req: AuthenticatedMedusaRequest<Body>,
  res: MedusaResponse
) {
  const merchantId = req.auth_context.actor_id
  const storeId = await getMerchantStoreId(req.scope, merchantId)

  const storeService = req.scope.resolve("store")

  const updated = await storeService.updateStores(storeId, {
    name: req.body.name,
  })

  res.json({ store: updated })
}
