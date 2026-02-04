import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { updateProductVariantsWorkflow } from "@medusajs/medusa/core-flows"
import { MedusaError } from "@medusajs/framework/utils"

type Body = {
  prices: {
    variant_id: string
    amount: number
    currency_code?: string
  }[]
}

export async function POST(
  req: AuthenticatedMedusaRequest<Body>,
  res: MedusaResponse
) {
  const merchantId = req.auth_context.actor_id
  const productId = req.params.id
  const { prices } = req.body

  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated"
    )
  }

  if (!Array.isArray(prices) || prices.length === 0) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Prices are required"
    )
  }

  await updateProductVariantsWorkflow(req.scope).run({
    input: {
      product_variants: prices.map(p => ({
        id: p.variant_id,
        prices: [
          {
            amount: Math.round(p.amount * 100),
            currency_code: p.currency_code || "usd",
          },
        ],
      })),
    },
  })

  res.json({ ok: true })
}
