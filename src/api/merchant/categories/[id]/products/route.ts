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
 * GET /merchant/categories/:id/products
 * List products belonging to a merchant category
 */
export async function GET(
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) {
  const merchantId = req.auth_context?.actor_id
  const categoryId = req.params.id

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

  // 1. Ensure category belongs to merchant
  const { rowCount: categoryCount } = await pool.query(
    `
    SELECT 1
    FROM merchant_categories
    WHERE id = $1
      AND sales_channel_id = $2
    `,
    [categoryId, merchant.sales_channel_id]
  )

  if (categoryCount === 0) {
    throw new MedusaError(
      MedusaError.Types.NOT_FOUND,
      "Category not found"
    )
  }

  // 2. Fetch products
  const { rows: products } = await pool.query(
    `
    SELECT p.*
    FROM product p
    INNER JOIN merchant_category_products mcp
      ON mcp.product_id = p.id
    WHERE mcp.category_id = $1
      AND p.deleted_at IS NULL
    ORDER BY p.created_at DESC
    `,
    [categoryId]
  )

  res.json({ products })
}

/**
 * POST /merchant/categories/:id/products
 * Attach product to a merchant category
 */
export async function POST(
  req: AuthenticatedMedusaRequest<AddProductBody>,
  res: MedusaResponse
) {
  const merchantId = req.auth_context?.actor_id
  const categoryId = req.params.id
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

  // 1. Ensure category belongs to merchant
  const { rowCount: categoryCount } = await pool.query(
    `
    SELECT 1
    FROM merchant_categories
    WHERE id = $1
      AND sales_channel_id = $2
    `,
    [categoryId, merchant.sales_channel_id]
  )

  if (categoryCount === 0) {
    throw new MedusaError(
      MedusaError.Types.NOT_FOUND,
      "Category not found"
    )
  }

  // 2. Ensure product belongs to merchant (via sales channel)
  const { rowCount: productCount } = await pool.query(
    `
    SELECT 1
    FROM product_sales_channel
    WHERE product_id = $1
      AND sales_channel_id = $2
      AND deleted_at IS NULL
    `,
    [product_id, merchant.sales_channel_id]
  )

  if (productCount === 0) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Product does not belong to this merchant"
    )
  }

  // 3. Attach product (idempotent)
  await pool.query(
    `
    INSERT INTO merchant_category_products (category_id, product_id)
    VALUES ($1, $2)
    ON CONFLICT DO NOTHING
    `,
    [categoryId, product_id]
  )

  res.status(201).json({
    category_id: categoryId,
    product_id,
  })
}
