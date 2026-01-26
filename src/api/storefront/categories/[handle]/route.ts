import { pool } from "../../../../lib/db"

export async function GET(req, res) {
  const { handle } = req.params
  const { sales_channel_id } = req.query

  if (!sales_channel_id) {
    return res.status(400).json({
      message: "sales_channel_id is required",
    })
  }

  // 1️⃣ Resolve category
  const categoryRes = await pool.query(
    `
    SELECT id, title, handle
    FROM merchant_categories
    WHERE handle = $1
      AND sales_channel_id = $2
    `,
    [handle, sales_channel_id]
  )

  if (categoryRes.rowCount === 0) {
    return res.status(404).json({ message: "Category not found" })
  }

  const category = categoryRes.rows[0]

  // 2️⃣ Fetch products in category (AND in sales channel)
  const productsRes = await pool.query(
    `
    SELECT p.id, p.title, p.handle, p.thumbnail
    FROM product p
    JOIN merchant_category_products mcp
      ON mcp.product_id = p.id
    JOIN product_sales_channel psc
      ON psc.product_id = p.id
    WHERE mcp.category_id = $1
      AND psc.sales_channel_id = $2
      AND p.status = 'published'
    `,
    [category.id, sales_channel_id]
  )

  return res.json({
    category,
    products: productsRes.rows,
  })
}
