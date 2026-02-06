import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { createPriceListPricesWorkflow } from "@medusajs/medusa/core-flows"

type Body = {
  prices: {
    variant_id: string
    currency_code: string
    amount: number
  }[]
}

// 🔒 Ownership enforcement helper (file-local, not abstracted)
async function assertSaleOwnership(
  query: any,
  saleId: string,
  storeId: string
) {
  const { data } = await query.graph({
    entity: "price_list",
    fields: [
      "id",
      "price_list_rules.attribute",
      "price_list_rules.value",
    ],
    filters: {
      id: saleId,
    },
  })

  const sale = data?.[0]

  if (!sale) {
    throw new MedusaError(
      MedusaError.Types.NOT_FOUND,
      "Sale not found"
    )
  }

  const owns = sale.price_list_rules?.some(
    (r: any) =>
      r.attribute === "store_id" &&
      r.value?.includes(storeId)
  )

  if (!owns) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Sale does not belong to this merchant"
    )
  }
}

export async function POST(
  req: AuthenticatedMedusaRequest<Body>,
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

  const saleId = req.params.id
  if (!saleId) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Sale id is required"
    )
  }

  // 🔒 Enforce ownership BEFORE mutation
  await assertSaleOwnership(query, saleId, merchant.store_id)

  const { prices } = req.body

  if (!prices || prices.length === 0) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "prices array is required"
    )
  }

  const { result } = await createPriceListPricesWorkflow(req.scope).run({
    input: {
      data: [
        {
          id: saleId,
          prices: prices.map((p) => ({
            variant_id: p.variant_id,
            currency_code: p.currency_code,
            amount: p.amount,
          })),
        },
      ],
    },
  })

  res.status(201).json({
    prices: result,
  })
}



// import {
//   AuthenticatedMedusaRequest,
//   MedusaResponse,
// } from "@medusajs/framework/http"
// import { MedusaError } from "@medusajs/framework/utils"
// import { createPriceListPricesWorkflow } from "@medusajs/medusa/core-flows"

// type Body = {
//   prices: {
//     variant_id: string
//     currency_code: string
//     amount: number
//   }[]
// }

// export async function POST(
//   req: AuthenticatedMedusaRequest<Body>,
//   res: MedusaResponse
// ) {
//   const merchantId = req.auth_context.actor_id
//   if (!merchantId) {
//     throw new MedusaError(
//       MedusaError.Types.UNAUTHORIZED,
//       "Not authenticated as merchant"
//     )
//   }

//   const saleId = req.params.id
//   if (!saleId) {
//     throw new MedusaError(
//       MedusaError.Types.INVALID_DATA,
//       "Sale id is required"
//     )
//   }

//   const { prices } = req.body

//   if (!prices || prices.length === 0) {
//     throw new MedusaError(
//       MedusaError.Types.INVALID_DATA,
//       "prices array is required"
//     )
//   }

//   const query = req.scope.resolve("query")

//   const { result } = await createPriceListPricesWorkflow(req.scope).run({
//     input: {
//       data: [
//         {
//           id: saleId,
//           prices: prices.map((p) => ({
//             variant_id: p.variant_id,
//             currency_code: p.currency_code,
//             amount: p.amount,
//           })),
//         },
//       ],
//     },
//   })

//   res.status(201).json({
//     prices: result,
//   })
// }
