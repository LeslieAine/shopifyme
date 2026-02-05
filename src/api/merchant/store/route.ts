//src/api/merchant/store/route.ts
import type {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import createStoreForMerchantWorkflow from "../../../workflows/create-store-for-merchant"


type Body = {
  name: string
}

export async function POST(
  req: AuthenticatedMedusaRequest<Body>,
  res: MedusaResponse
) {
  // If merchant already has a store, block
  if (req.auth_context.actor_id === undefined) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated as merchant"
    )
  }

  const { result } = await createStoreForMerchantWorkflow(
    req.scope
  ).run({
    input: {
      merchantId: req.auth_context.actor_id,
      store: {
        name: req.body.name,
      },
    },
  })

  res.status(201).json(result)
}
