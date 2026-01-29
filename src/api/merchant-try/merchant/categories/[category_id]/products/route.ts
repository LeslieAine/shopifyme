import { pool } from "../../../../../../lib/db"

export const config = {
  auth: { actor: "merchant" },
}

/**
 * CORS preflight
 */
export async function OPTIONS(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "http://localhost:3000")
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, DELETE, OPTIONS")
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
  res.setHeader("Access-Control-Allow-Credentials", "true")
  return res.status(204).end()
}

/**
 * GET – product IDs in category
 */
export async function GET(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "http://localhost:3000")
  res.setHeader("Access-Control-Allow-Credentials", "true")

  const { category_id } = req.params
  const { sales_channel_id } = req.query

  const owns = await pool.query(
    `
    SELECT 1 FROM merchant_categories
    WHERE id = $1 AND sales_channel_id = $2
    `,
    [category_id, sales_channel_id]
  )

  if (owns.rowCount === 0) {
    return res.status(403).json({ message: "Forbidden" })
  }

  const { rows } = await pool.query(
    `
    SELECT product_id
    FROM merchant_category_products
    WHERE category_id = $1
    `,
    [category_id]
  )

  return res.json({
    product_ids: rows.map((r) => r.product_id),
  })
}

/**
 * POST – attach product
 */
export async function POST(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "http://localhost:3000")
  res.setHeader("Access-Control-Allow-Credentials", "true")

  const { category_id } = req.params
  const { product_id, sales_channel_id } = req.body

  const owns = await pool.query(
    `
    SELECT 1 FROM merchant_categories
    WHERE id = $1 AND sales_channel_id = $2
    `,
    [category_id, sales_channel_id]
  )

  if (owns.rowCount === 0) {
    return res.status(403).json({ message: "Forbidden" })
  }

  await pool.query(
    `
    INSERT INTO merchant_category_products (category_id, product_id)
    VALUES ($1, $2)
    ON CONFLICT DO NOTHING
    `,
    [category_id, product_id]
  )

  return res.json({ success: true })
}

/**
 * DELETE – detach product
 */
export async function DELETE(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "http://localhost:3000")
  res.setHeader("Access-Control-Allow-Credentials", "true")

  const { category_id } = req.params
  const { product_id, sales_channel_id } = req.query

  const owns = await pool.query(
    `
    SELECT 1 FROM merchant_categories
    WHERE id = $1 AND sales_channel_id = $2
    `,
    [category_id, sales_channel_id]
  )

  if (owns.rowCount === 0) {
    return res.status(403).json({ message: "Forbidden" })
  }

  await pool.query(
    `
    DELETE FROM merchant_category_products
    WHERE category_id = $1 AND product_id = $2
    `,
    [category_id, product_id]
  )

  return res.json({ success: true })
}
