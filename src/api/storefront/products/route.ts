import { pool } from "../../../lib/db"

export async function GET(req, res) {
  const { sales_channel_id } = req.query

  if (!sales_channel_id) {
    return res.status(400).json({
      message: "sales_channel_id is required",
    })
  }

  const { rows } = await pool.query(
    `
    SELECT
      p.id,
      p.title,
      p.handle,
      p.thumbnail
    FROM product p
    JOIN product_sales_channel psc
      ON psc.product_id = p.id
    WHERE psc.sales_channel_id = $1
      AND p.status = 'published'
    ORDER BY p.created_at DESC
    `,
    [sales_channel_id]
  )

  return res.json({ products: rows })
}
