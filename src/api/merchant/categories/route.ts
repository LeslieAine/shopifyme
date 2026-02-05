import type {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { ulid } from "ulid"
import { pool } from "../../../lib/db"

type CreateCategoryBody = {
  title: string
  handle: string
}

export const config = {
  auth: {
    actor: "merchant",
  },
}

/**
 * GET /merchant/categories
 * List categories belonging to the merchant (via sales channel)
 */
export async function GET(
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) {
  const merchantId = req.auth_context?.actor_id

  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated as merchant"
    )
  }

  const merchantService = req.scope.resolve("merchant")
  const merchant = await merchantService.retrieveMerchant(merchantId)

  if (!merchant.sales_channel_id) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Merchant has no sales channel"
    )
  }

  const { rows } = await pool.query(
    `
    SELECT id, title, handle, created_at
    FROM merchant_categories
    WHERE sales_channel_id = $1
    ORDER BY created_at DESC
    `,
    [merchant.sales_channel_id]
  )

  res.json({ categories: rows })
}

/**
 * POST /merchant/categories
 * Create a category scoped to merchant sales channel
 */
export async function POST(
  req: AuthenticatedMedusaRequest<CreateCategoryBody>,
  res: MedusaResponse
) {
  const merchantId = req.auth_context?.actor_id
  const { title, handle } = req.body

  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated as merchant"
    )
  }

  if (!title || !handle) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "title and handle are required"
    )
  }

  const merchantService = req.scope.resolve("merchant")
  const merchant = await merchantService.retrieveMerchant(merchantId)

  if (!merchant.sales_channel_id) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Merchant has no sales channel"
    )
  }

  // 🔑 ONLY ADDITION — deterministic ID
  const categoryId = `mcat_${ulid()}`

  const { rows } = await pool.query(
    `
    INSERT INTO merchant_categories
      (id, sales_channel_id, title, handle)
    VALUES ($1, $2, $3, $4)
    RETURNING id, title, handle
    `,
    [categoryId, merchant.sales_channel_id, title, handle]
  )

  res.status(201).json({ category: rows[0] })
}



// import type {
//   AuthenticatedMedusaRequest,
//   MedusaResponse,
// } from "@medusajs/framework/http"
// import { MedusaError } from "@medusajs/framework/utils"
// import { pool } from "../../../lib/db"

// type CreateCategoryBody = {
//   title: string
//   handle: string
// }

// export const config = {
//   auth: {
//     actor: "merchant",
//   },
// }

// /**
//  * GET /merchant/categories
//  * List categories belonging to the merchant (via sales channel)
//  */
// export async function GET(
//   req: AuthenticatedMedusaRequest,
//   res: MedusaResponse
// ) {
//   const merchantId = req.auth_context?.actor_id

//   if (!merchantId) {
//     throw new MedusaError(
//       MedusaError.Types.UNAUTHORIZED,
//       "Not authenticated as merchant"
//     )
//   }

//   const merchantService = req.scope.resolve("merchant")
//   const merchant = await merchantService.retrieveMerchant(merchantId)

//   if (!merchant.sales_channel_id) {
//     throw new MedusaError(
//       MedusaError.Types.INVALID_DATA,
//       "Merchant has no sales channel"
//     )
//   }

//   const { rows } = await pool.query(
//     `
//     SELECT id, title, handle, created_at
//     FROM merchant_categories
//     WHERE sales_channel_id = $1
//     ORDER BY created_at DESC
//     `,
//     [merchant.sales_channel_id]
//   )

//   res.json({ categories: rows })
// }

// /**
//  * POST /merchant/categories
//  * Create a category scoped to merchant sales channel
//  */
// export async function POST(
//   req: AuthenticatedMedusaRequest<CreateCategoryBody>,
//   res: MedusaResponse
// ) {
//   const merchantId = req.auth_context?.actor_id
//   const { title, handle } = req.body

//   if (!merchantId) {
//     throw new MedusaError(
//       MedusaError.Types.UNAUTHORIZED,
//       "Not authenticated as merchant"
//     )
//   }

//   if (!title || !handle) {
//     throw new MedusaError(
//       MedusaError.Types.INVALID_DATA,
//       "title and handle are required"
//     )
//   }

//   const merchantService = req.scope.resolve("merchant")
//   const merchant = await merchantService.retrieveMerchant(merchantId)

//   if (!merchant.sales_channel_id) {
//     throw new MedusaError(
//       MedusaError.Types.INVALID_DATA,
//       "Merchant has no sales channel"
//     )
//   }

//   const { rows } = await pool.query(
//     `
//     INSERT INTO merchant_categories
//       (sales_channel_id, title, handle)
//     VALUES ($1, $2, $3)
//     RETURNING id, title, handle
//     `,
//     [merchant.sales_channel_id, title, handle]
//   )

//   res.status(201).json({ category: rows[0] })
// }
