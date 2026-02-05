// src/api/merchant/regions/route.ts
import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { createRegionsWorkflow } from "@medusajs/medusa/core-flows"

type Body = {
  name: string
  currency_code: string
  countries: string[]
}

export async function POST(
  req: AuthenticatedMedusaRequest<Body>,
  res: MedusaResponse
) {
  // ✅ SAME PATTERN AS YOUR WORKING ROUTES
  const merchantId = req.auth_context.actor_id

  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated as merchant"
    )
  }

  const { name, currency_code, countries } = req.body

  if (!name || !currency_code || !countries?.length) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "name, currency_code, and countries are required"
    )
  }

  const { result } = await createRegionsWorkflow(req.scope).run({
    input: {
      regions: [
        {
          name,
          currency_code,
          countries,
          metadata: {
            merchant_id: merchantId,
          },
        },
      ],
    },
  })

  res.status(201).json({ region: result[0] })
}

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

  const query = req.scope.resolve("query")

  const { data: regions } = await query.graph({
    entity: "region",
    fields: [
      "id",
      "name",
      "currency_code",
      "countries.iso_2",
    ],
  })

  res.json({ regions })
}
