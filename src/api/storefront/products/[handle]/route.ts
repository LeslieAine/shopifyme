import { pool } from "../../../../lib/db"

export async function GET(req, res) {
  const { handle } = req.params
  const { sales_channel_id } = req.query

  if (!sales_channel_id) {
    return res.status(400).json({
      message: "sales_channel_id is required",
    })
  }

  const productRes = await pool.query(
    `
    SELECT
      p.id,
      p.title,
      p.handle,
      p.description,
      p.thumbnail
    FROM product p
    JOIN product_sales_channel psc
      ON psc.product_id = p.id
    WHERE p.handle = $1
      AND psc.sales_channel_id = $2
      AND p.status = 'published'
    `,
    [handle, sales_channel_id]
  )

  if (productRes.rowCount === 0) {
    return res.status(404).json({ message: "Product not found" })
  }

  return res.json({ product: productRes.rows[0] })
}
