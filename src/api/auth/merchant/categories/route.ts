import { pool } from "../../../../lib/db"

export const config = {
  auth: { actor: "merchant" },
}

export async function GET(req, res) {
  const { sales_channel_id } = req.query

  if (!sales_channel_id) {
    return res.status(400).json({
      message: "sales_channel_id is required",
    })
  }

  const { rows } = await pool.query(
    `
    SELECT id, title, handle
    FROM merchant_categories
    WHERE sales_channel_id = $1
    ORDER BY created_at DESC
    `,
    [sales_channel_id]
  )

  return res.json({ categories: rows })
}
