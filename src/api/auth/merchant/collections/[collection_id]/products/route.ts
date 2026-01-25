
import { pool } from "../../../../../../lib/db"

export const config = {
  auth: {
    actor: "merchant",
  },
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
 * GET – fetch product IDs attached to this collection
 */
export async function GET(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "http://localhost:3000")
  res.setHeader("Access-Control-Allow-Credentials", "true")

  const { collection_id } = req.params
  const { sales_channel_id } = req.query

  if (!sales_channel_id) {
    return res.status(400).json({
      message: "sales_channel_id is required",
    })
  }

  const owns = await pool.query(
    `
    SELECT 1
    FROM merchant_collections
    WHERE id = $1 AND sales_channel_id = $2
    `,
    [collection_id, sales_channel_id]
  )

  if (owns.rowCount === 0) {
    return res.status(403).json({ message: "Forbidden" })
  }

  const { rows } = await pool.query(
    `
    SELECT product_id
    FROM merchant_collection_products
    WHERE collection_id = $1
    `,
    [collection_id]
  )

  return res.json({
    product_ids: rows.map((r) => r.product_id),
  })
}

/**
 * POST – attach product to collection
 */
export async function POST(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "http://localhost:3000")
  res.setHeader("Access-Control-Allow-Credentials", "true")

  const { collection_id } = req.params
  const { product_id, sales_channel_id } = req.body

  if (!product_id || !sales_channel_id) {
    return res.status(400).json({
      message: "product_id and sales_channel_id are required",
    })
  }

  const owns = await pool.query(
    `
    SELECT 1
    FROM merchant_collections
    WHERE id = $1 AND sales_channel_id = $2
    `,
    [collection_id, sales_channel_id]
  )

  if (owns.rowCount === 0) {
    return res.status(403).json({ message: "Forbidden" })
  }

  await pool.query(
    `
    INSERT INTO merchant_collection_products (collection_id, product_id)
    VALUES ($1, $2)
    ON CONFLICT DO NOTHING
    `,
    [collection_id, product_id]
  )

  return res.json({ success: true })
}

/**
 * DELETE – remove product from collection
 */
export async function DELETE(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "http://localhost:3000")
  res.setHeader("Access-Control-Allow-Credentials", "true")

  const { collection_id } = req.params
  const { product_id, sales_channel_id } = req.query

  if (!product_id || !sales_channel_id) {
    return res.status(400).json({
      message: "product_id and sales_channel_id are required",
    })
  }

  const owns = await pool.query(
    `
    SELECT 1
    FROM merchant_collections
    WHERE id = $1 AND sales_channel_id = $2
    `,
    [collection_id, sales_channel_id]
  )

  if (owns.rowCount === 0) {
    return res.status(403).json({ message: "Forbidden" })
  }

  await pool.query(
    `
    DELETE FROM merchant_collection_products
    WHERE collection_id = $1 AND product_id = $2
    `,
    [collection_id, product_id]
  )

  return res.json({ success: true })
}


// import { pool } from "../../../../../../lib/db"

// export const config = {
//   auth: {
//     actor: "merchant",
//   },
// }

// /**
//  * CORS preflight
//  */
// export async function OPTIONS(req, res) {
//   res.setHeader("Access-Control-Allow-Origin", "http://localhost:3000")
//   res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
//   res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
//   res.setHeader("Access-Control-Allow-Credentials", "true")
//   return res.status(204).end()
// }

// /**
//  * GET – fetch product IDs attached to this collection
//  */
// export async function GET(req, res) {
//   res.setHeader("Access-Control-Allow-Origin", "http://localhost:3000")
//   res.setHeader("Access-Control-Allow-Credentials", "true")

//   const { collection_id } = req.params
//   const { sales_channel_id } = req.query

//   if (!sales_channel_id) {
//     return res.status(400).json({
//       message: "sales_channel_id is required",
//     })
//   }

//   // verify ownership via sales channel
//   const owns = await pool.query(
//     `
//     SELECT 1
//     FROM merchant_collections
//     WHERE id = $1 AND sales_channel_id = $2
//     `,
//     [collection_id, sales_channel_id]
//   )

//   if (owns.rowCount === 0) {
//     return res.status(403).json({ message: "Forbidden" })
//   }

//   const { rows } = await pool.query(
//     `
//     SELECT product_id
//     FROM merchant_collection_products
//     WHERE collection_id = $1
//     `,
//     [collection_id]
//   )

//   return res.json({
//     product_ids: rows.map((r) => r.product_id),
//   })
// }

// /**
//  * POST – attach product to collection
//  */
// export async function POST(req, res) {
//   res.setHeader("Access-Control-Allow-Origin", "http://localhost:3000")
//   res.setHeader("Access-Control-Allow-Credentials", "true")

//   const { collection_id } = req.params
//   const { product_id, sales_channel_id } = req.body

//   if (!product_id || !sales_channel_id) {
//     return res.status(400).json({
//       message: "product_id and sales_channel_id are required",
//     })
//   }

//   const owns = await pool.query(
//     `
//     SELECT 1
//     FROM merchant_collections
//     WHERE id = $1 AND sales_channel_id = $2
//     `,
//     [collection_id, sales_channel_id]
//   )

//   if (owns.rowCount === 0) {
//     return res.status(403).json({ message: "Forbidden" })
//   }

//   await pool.query(
//     `
//     INSERT INTO merchant_collection_products (collection_id, product_id)
//     VALUES ($1, $2)
//     ON CONFLICT DO NOTHING
//     `,
//     [collection_id, product_id]
//   )

//   return res.json({ success: true })
// }



// // import { batchLinkProductsToCollectionWorkflow } from "@medusajs/medusa/core-flows"

// // export const config = {
// //   auth: {
// //     actor: "merchant",
// //   },
// // }

// // export async function POST(req, res) {
// //   const { collection_id } = req.params
// //   const { product_id } = req.body

// //   if (!product_id) {
// //     return res.status(400).json({
// //       message: "product_id is required",
// //     })
// //   }

// //   await batchLinkProductsToCollectionWorkflow(req.scope).run({
// //     input: {
// //       id: collection_id,
// //       add: [product_id],
// //     },
// //   })

// //   return res.json({ success: true })
// // }

// import { pool } from "../../../../../../lib/db"

// export const config = {
//   auth: {
//     actor: "merchant",
//   },
// }

// export async function POST(req, res) {
//   const { collection_id } = req.params
//   const { product_id, sales_channel_id } = req.body

//   if (!product_id || !sales_channel_id) {
//     return res.status(400).json({
//       message: "product_id and sales_channel_id are required",
//     })
//   }

//   // Verify collection belongs to sales channel
//   const owns = await pool.query(
//     `
//     SELECT 1
//     FROM merchant_collections
//     WHERE id = $1 AND sales_channel_id = $2
//     `,
//     [collection_id, sales_channel_id]
//   )

//   if (owns.rowCount === 0) {
//     return res.status(403).json({ message: "Forbidden" })
//   }

//   await pool.query(
//     `
//     INSERT INTO merchant_collection_products (collection_id, product_id)
//     VALUES ($1, $2)
//     ON CONFLICT DO NOTHING
//     `,
//     [collection_id, product_id]
//   )

//   return res.json({ success: true })
// }
