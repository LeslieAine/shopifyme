import { pool } from "../../../../lib/db"

export async function GET(req, res) {
  const { handle } = req.params
  const { sales_channel_id } = req.query

  if (!sales_channel_id) {
    return res.status(400).json({ message: "sales_channel_id required" })
  }

  // 1️⃣ Find collection
  const collectionRes = await pool.query(
    `
    SELECT id, title, handle
    FROM merchant_collections
    WHERE handle = $1
      AND sales_channel_id = $2
    `,
    [handle, sales_channel_id]
  )

  if (collectionRes.rowCount === 0) {
    return res.status(404).json({ message: "Collection not found" })
  }

  const collection = collectionRes.rows[0]

  // 2️⃣ Fetch products
  const productsRes = await pool.query(
    `
    SELECT p.id, p.title
    FROM product p
    JOIN merchant_collection_products mcp
      ON mcp.product_id = p.id
    WHERE mcp.collection_id = $1
    `,
    [collection.id]
  )

  return res.json({
    collection,
    products: productsRes.rows,
  })
}