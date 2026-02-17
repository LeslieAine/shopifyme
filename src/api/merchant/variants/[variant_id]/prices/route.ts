// src/api/merchant/variants/[variant_id]/prices/route.ts
import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { Modules } from "@medusajs/framework/utils"

type Body = {
  amount: number
  currency_code: string
  region_id: string
}

export async function POST(
  req: AuthenticatedMedusaRequest<Body>,
  res: MedusaResponse
) {
  const merchantId = req.auth_context.actor_id
  const { variant_id } = req.params
  const { amount, currency_code, region_id } = req.body

  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated"
    )
  }

  if (!amount || !currency_code || !region_id) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "amount, currency_code, region_id are required"
    )
  }

  const query = req.scope.resolve("query")
  const pricingService = req.scope.resolve(Modules.PRICING)

  /**
   * 1️⃣ Load variant + its EXISTING price_set_id
   */
  const { data: variants } = await query.graph({
    entity: "variant",
    fields: ["id", "price_set.id"],
    filters: { id: variant_id },
  })

  const priceSetId = variants?.[0]?.price_set?.id

  if (!priceSetId) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Variant has no price set"
    )
  }

  /**
   * 2️⃣ Add a REGION-SPECIFIC price to the SAME price set
   *    (NO new links, NO new price sets)
   */
  await pricingService.addPrices({
    priceSetId,
    prices: [
      {
        amount: Math.round(amount * 100),
        currency_code,
        rules: {
          region_id,
        },
      },
    ],
  })

  res.json({ ok: true })
}
