// src/api/merchant/collections/[id]/products/route.ts
import type {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { pool } from "../../../../../lib/db"

type AddProductBody = {
  product_id: string
}

/**
 * GET /merchant/collections/:id/products
 * List products belonging to a merchant collection
 */
export async function GET(
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) {
  const merchantId = req.auth_context?.actor_id
  const collectionId = req.params.id

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

  /**
   * Ensure collection belongs to merchant
   */
  const collectionCheck = await pool.query(
    `
    SELECT id
    FROM merchant_collections
    WHERE id = $1
      AND sales_channel_id = $2
    `,
    [collectionId, merchant.sales_channel_id]
  )

  if (collectionCheck.rowCount === 0) {
    throw new MedusaError(
      MedusaError.Types.NOT_FOUND,
      "Collection not found"
    )
  }

  /**
   * Fetch products through merchant_collection_products
   */
  const { rows: products } = await pool.query(
    `
    SELECT p.*
    FROM product p
    INNER JOIN merchant_collection_products mcp
      ON mcp.product_id = p.id
    WHERE mcp.collection_id = $1
      AND p.deleted_at IS NULL
    ORDER BY p.created_at DESC
    `,
    [collectionId]
  )

  res.json({ products })
}

/**
 * POST /merchant/collections/:id/products
 * Attach product to a merchant collection
 */
export async function POST(
  req: AuthenticatedMedusaRequest<AddProductBody>,
  res: MedusaResponse
) {
  const merchantId = req.auth_context?.actor_id
  const collectionId = req.params.id
  const { product_id } = req.body

  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated as merchant"
    )
  }

  if (!product_id) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "product_id is required"
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

  /**
   * 1. Verify collection belongs to merchant
   */
  const collectionCheck = await pool.query(
    `
    SELECT id
    FROM merchant_collections
    WHERE id = $1
      AND sales_channel_id = $2
    `,
    [collectionId, merchant.sales_channel_id]
  )

  if (collectionCheck.rowCount === 0) {
    throw new MedusaError(
      MedusaError.Types.NOT_FOUND,
      "Collection not found"
    )
  }

  /**
   * 2. Verify product belongs to merchant (via sales channel)
   */
  const productCheck = await pool.query(
    `
    SELECT product_id
    FROM product_sales_channel
    WHERE product_id = $1
      AND sales_channel_id = $2
      AND deleted_at IS NULL
    `,
    [product_id, merchant.sales_channel_id]
  )

  if (productCheck.rowCount === 0) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Product does not belong to this merchant"
    )
  }

  /**
   * 3. Attach product to collection (idempotent)
   */
  await pool.query(
    `
    INSERT INTO merchant_collection_products (collection_id, product_id)
    VALUES ($1, $2)
    ON CONFLICT DO NOTHING
    `,
    [collectionId, product_id]
  )

  res.status(201).json({
    collection_id: collectionId,
    product_id,
  })
}
