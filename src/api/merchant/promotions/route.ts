import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { createPromotionsWorkflow } from "@medusajs/medusa/core-flows"

type Body = {
  code: string
  status?: "draft" | "active" | "inactive"
  type?: "standard"
  is_automatic?: boolean
  application_method: {
    type: "percentage" | "fixed"
    target_type: "items" | "order"
    allocation?: "across"
    value: number
    currency_code?: string
  }
}

export async function POST(
  req: AuthenticatedMedusaRequest<Body>,
  res: MedusaResponse
) {
  const merchantId = req.auth_context.actor_id

  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated as merchant"
    )
  }

  // ✅ ADD THIS
  const merchantService = req.scope.resolve("merchant")
  const merchant = await merchantService.retrieveMerchant(merchantId)

  if (!merchant.sales_channel_id) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Merchant has no sales channel"
    )
  }

  const { result } = await createPromotionsWorkflow(req.scope).run({
    input: {
      promotionsData: [
        {
          code: req.body.code,
          type: req.body.type ?? "standard",
          status: req.body.status ?? "draft",
          is_automatic: req.body.is_automatic ?? false,
          application_method: {
            type: req.body.application_method.type,
            target_type: req.body.application_method.target_type,
            allocation: req.body.application_method.allocation ?? "across",
            value: req.body.application_method.value,
            currency_code: req.body.application_method.currency_code,
          },

          // ✅ THIS is the only real change
          rules: [
            {
              attribute: "sales_channel_id",
              operator: "eq",
              values: [merchant.sales_channel_id],
            },
          ],
        },
      ],

      additional_data: {
        merchant_id: merchantId,
      },
    },
  })

  res.status(201).json({
    promotion: result[0],
  })
}



// import {
//   AuthenticatedMedusaRequest,
//   MedusaResponse,
// } from "@medusajs/framework/http"
// import { MedusaError } from "@medusajs/framework/utils"
// import { createPromotionsWorkflow } from "@medusajs/medusa/core-flows"

// type Body = {
//   code: string
//   status?: "draft" | "active" | "inactive"
//   type?: "standard"
//   is_automatic?: boolean
//   application_method: {
//     type: "percentage" | "fixed"
//     target_type: "items" | "order"
//     allocation?: "across"
//     value: number
//     currency_code?: string
//   }
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

//   const { result } = await createPromotionsWorkflow(req.scope).run({
//     input: {
//       promotionsData: [
//         {
//           code: req.body.code,
//           type: req.body.type ?? "standard",
//           status: req.body.status ?? "draft",
//           is_automatic: req.body.is_automatic ?? false,
//           application_method: {
//             type: req.body.application_method.type,
//             target_type: req.body.application_method.target_type,
//             allocation: req.body.application_method.allocation ?? "across",
//             value: req.body.application_method.value,
//             currency_code: req.body.application_method.currency_code,
//           },
//         },
//       ],
//       additional_data: {
//         merchant_id: merchantId,
//       },
//     },
//   })

//   res.status(201).json({
//     promotion: result[0],
//   })
// }
