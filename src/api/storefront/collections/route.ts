import { pool } from "../../../lib/db"

export async function GET(req, res) {
  const { sales_channel_id } = req.query

  if (!sales_channel_id) {
    return res.status(400).json({ message: "sales_channel_id required" })
  }

  const { rows } = await pool.query(
    `
    SELECT id, title, handle
    FROM merchant_collections
    WHERE sales_channel_id = $1
    ORDER BY created_at DESC
    `,
    [sales_channel_id]
  )

  return res.json({ collections: rows })
}
