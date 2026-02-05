// src/api/merchant/products/[id]/variants/prices/route.ts

import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { updateProductVariantsWorkflow } from "@medusajs/medusa/core-flows"

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

  // ✅ BASE PRICE ONLY — NO REGIONS, NO RULES
  await updateProductVariantsWorkflow(req.scope).run({
    input: {
      product_variants: prices.map((p) => ({
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



// // src/api/merchant/products/[id]/variants/prices/route.ts
// import {
//   AuthenticatedMedusaRequest,
//   MedusaResponse,
// } from "@medusajs/framework/http"
// import { MedusaError } from "@medusajs/framework/utils"
// import { upsertVariantPricesWorkflow } from "@medusajs/medusa/core-flows"

// type Body = {
//   prices: {
//     variant_id: string
//     amount: number
//     currency_code: string
//     region_id?: string
//   }[]
// }

// export async function POST(
//   req: AuthenticatedMedusaRequest<Body>,
//   res: MedusaResponse
// ) {
//   const merchantId = req.auth_context.actor_id
//   const productId = req.params.id
//   const { prices } = req.body

//   if (!merchantId) {
//     throw new MedusaError(
//       MedusaError.Types.UNAUTHORIZED,
//       "Not authenticated"
//     )
//   }

//   if (!Array.isArray(prices) || prices.length === 0) {
//     throw new MedusaError(
//       MedusaError.Types.INVALID_DATA,
//       "Prices are required"
//     )
//   }

//   /**
//    * 1️⃣ Group prices by variant_id
//    */
//   const byVariant = new Map<string, any[]>()

//   for (const p of prices) {
//     if (!byVariant.has(p.variant_id)) {
//       byVariant.set(p.variant_id, [])
//     }

//     byVariant.get(p.variant_id)!.push({
//       amount: Math.round(p.amount * 100),
//       currency_code: p.currency_code,
//       rules: p.region_id
//         ? { region_id: p.region_id }
//         : {},
//     })
//   }

//   /**
//    * 2️⃣ Upsert prices ONCE per variant
//    *    (DO NOT recreate product↔pricing link)
//    */
//   await upsertVariantPricesWorkflow(req.scope).run({
//     input: {
//       variantPrices: Array.from(byVariant.entries()).map(
//         ([variant_id, prices]) => ({
//           variant_id,
//           product_id: productId, // REQUIRED by TS, SAFE at runtime
//           prices,
//         })
//       ),
//       previousVariantIds: [],
//     },
//   })

//   res.json({ ok: true })
// }



// // import {
// //   AuthenticatedMedusaRequest,
// //   MedusaResponse,
// // } from "@medusajs/framework/http"
// // import { updateProductVariantsWorkflow, upsertVariantPricesWorkflow } from "@medusajs/medusa/core-flows"
// // import { MedusaError } from "@medusajs/framework/utils"

// // type Body = {
// //   prices: {
// //     variant_id: string
// //     amount: number
// //     currency_code?: string
// //   }[]
// // }

// // export async function POST(
// //   req: AuthenticatedMedusaRequest<Body>,
// //   res: MedusaResponse
// // ) {
// //   const merchantId = req.auth_context.actor_id
// //   const productId = req.params.id
// //   const { prices } = req.body

// //   if (!merchantId) {
// //     throw new MedusaError(
// //       MedusaError.Types.UNAUTHORIZED,
// //       "Not authenticated"
// //     )
// //   }

// //   if (!Array.isArray(prices) || prices.length === 0) {
// //     throw new MedusaError(
// //       MedusaError.Types.INVALID_DATA,
// //       "Prices are required"
// //     )
// //   }

// //   await updateProductVariantsWorkflow(req.scope).run({
// //     input: {
// //       product_variants: prices.map(p => ({
// //         id: p.variant_id,
// //         prices: [
// //           {
// //             amount: Math.round(p.amount * 100),
// //             currency_code: p.currency_code || "usd",
// //           },
// //         ],
// //       })),
// //     },
// //   })

// //   res.json({ ok: true })
// // }
