// src/api/merchant/collections/route.ts
import type {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { ulid } from "ulid"
import { pool } from "../../../lib/db"

type CreateCollectionBody = {
  title: string
  handle: string
  description?: string
}

export const config = {
  auth: {
    actor: "merchant",
  },
}

// /**
//  * GET /merchant/collections
//  * List collections belonging to the merchant (via sales channel)
//  */
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
    SELECT id, title, handle, description, created_at
    FROM merchant_collections
    WHERE sales_channel_id = $1
    ORDER BY created_at DESC
    `,
    [merchant.sales_channel_id]
  )

  res.json({ collections: rows })
}

export async function POST(
  req: AuthenticatedMedusaRequest<CreateCollectionBody>,
  res: MedusaResponse
) {
  const merchantId = req.auth_context?.actor_id
  const { title, handle, description } = req.body

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

  // 🔑 THIS IS THE FIX
  const collectionId = `mcol_${ulid()}`

  const { rows } = await pool.query(
    `
    INSERT INTO merchant_collections
      (id, sales_channel_id, title, handle, description)
    VALUES ($1, $2, $3, $4, $5)
    RETURNING id, title, handle, description
    `,
    [
      collectionId,
      merchant.sales_channel_id,
      title,
      handle,
      description ?? null,
    ]
  )

  res.status(201).json({ collection: rows[0] })
}
