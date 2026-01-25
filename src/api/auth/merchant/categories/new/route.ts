import { pool } from "../../../../../lib/db"
import slugify from "slugify"

export const config = {
  auth: { actor: "merchant" },
}

export async function POST(req, res) {
  const { title, sales_channel_id } = req.body

  if (!title || !sales_channel_id) {
    return res.status(400).json({
      message: "title and sales_channel_id are required",
    })
  }

  const handle = slugify(title, { lower: true })

  const { rows } = await pool.query(
    `
    INSERT INTO merchant_categories (title, handle, sales_channel_id)
    VALUES ($1, $2, $3)
    RETURNING id, title, handle
    `,
    [title, handle, sales_channel_id]
  )

  return res.status(201).json({ category: rows[0] })
}
