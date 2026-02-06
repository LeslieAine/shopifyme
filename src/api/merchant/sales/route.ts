import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { createPriceListsWorkflow } from "@medusajs/medusa/core-flows"
// import { PriceListService } from "@medusajs/medusa"

type Body = {
  title: string
  description?: string
  starts_at?: string
  ends_at?: string
  region_id?: string
}

export async function POST(
  req: AuthenticatedMedusaRequest<Body>,
  res: MedusaResponse
) {
  const merchantService = req.scope.resolve("merchant")

  const merchantId = req.auth_context.actor_id
  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated as merchant"
    )
  }

  const merchant = await merchantService.retrieveMerchant(merchantId)

  if (!merchant.store_id) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Merchant has no store"
    )
  }

  const { title, description, starts_at, ends_at, region_id } = req.body

  if (!title) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "title is required"
    )
  }

  const { result } = await createPriceListsWorkflow(req.scope).run({
    input: {
      price_lists_data: [
        {
          title,
          description: description ?? "",
          status: "active",
          starts_at,
          ends_at,
          rules: {
            store_id: [merchant.store_id],
            ...(region_id ? { region_id: [region_id] } : {}),
          },
        },
      ],
    },
  })

  res.status(201).json({
    sale: (result as any[])[0],
  })
}

export async function GET(
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) {
  const merchantService = req.scope.resolve("merchant")
  const query = req.scope.resolve("query")

  const merchantId = req.auth_context.actor_id
  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated as merchant"
    )
  }

  const merchant = await merchantService.retrieveMerchant(merchantId)

  if (!merchant.store_id) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Merchant has no store"
    )
  }

  const { data: priceLists } = await query.graph({
    entity: "price_list",
    fields: [
      "id",
      "title",
      "description",
      "status",
      "type",
      "starts_at",
      "ends_at",
      "created_at",
      "rules_count",
      "price_list_rules.attribute",
      "price_list_rules.value",
    ],
    pagination: {
      skip: 0,
      take: 50,
    },
  })

  // ⬇️ MANUAL merchant isolation (required in v2)
  const sales = priceLists.filter((pl: any) =>
    pl.price_list_rules?.some(
      (r: any) =>
        r.attribute === "store_id" &&
        r.value?.includes(merchant.store_id)
    )
  )

  res.json({
    sales,
    count: sales.length,
  })
}
