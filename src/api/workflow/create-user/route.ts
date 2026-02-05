import type {
  MedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"

import { createUserAccountWorkflow } from "@medusajs/medusa/core-flows"

export async function POST(
  req: MedusaRequest,
  res: MedusaResponse
) {
  const { auth_identity_id, email } = req.body as {
    auth_identity_id: string
    email: string
  }

  if (!auth_identity_id || !email) {
    return res.status(400).json({
      error: "auth_identity_id and email are required",
    })
  }

  const { result } = await createUserAccountWorkflow(req.scope).run({
    input: {
      authIdentityId: auth_identity_id,
      userData: {
        email,
      },
    },
  })

  res.json(result)
}
