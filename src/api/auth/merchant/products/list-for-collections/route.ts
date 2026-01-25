import { Modules } from "@medusajs/framework/utils"
import { pool } from "../../../../../lib/db"

export const config = {
  auth: {
    actor: "merchant",
  },
}

export async function GET(req, res) {
  const { sales_channel_id } = req.query

  if (!sales_channel_id) {
    return res.status(400).json({
      message: "sales_channel_id is required",
    })
  }

  const productService = req.scope.resolve(Modules.PRODUCT)

  /**
   * 1) Get product IDs linked to this sales channel
   *    (THIS is the correct source of truth)
   */
  const { rows } = await pool.query(
    `
    SELECT product_id
    FROM product_sales_channel
    WHERE sales_channel_id = $1
    `,
    [sales_channel_id]
  )

  const productIds = rows.map((r) => r.product_id)

  if (productIds.length === 0) {
    return res.json({ products: [] })
  }

  /**
   * 2) Fetch product details from Medusa Product service
   */
  const products = await productService.listProducts(
    { id: productIds },
    { select: ["id", "title"] }
  )

  return res.json({ products })
}
