// src/api/storefront/resolve/route.ts
import { pool } from "../../../lib/db"

export async function GET(req, res) {
  const { handle } = req.query

  if (!handle) {
    return res.status(400).json({
      message: "store handle is required",
    })
  }

  const { rows } = await pool.query(
    `
    SELECT
      id AS store_id,
      handle,
      default_sales_channel_id AS sales_channel_id
    FROM store
    WHERE handle = $1
      AND deleted_at IS NULL
    LIMIT 1
    `,
    [handle]
  )

  if (rows.length === 0) {
    return res.status(404).json({ message: "Store not found" })
  }

  return res.json(rows[0])
}
