import { pool } from "../../../../lib/db"

export const config = {
  auth: {
    actor: "merchant",
  },
}

export async function GET(req, res) {
  const merchantId = req.auth?.actor_id
  const { sales_channel_id } = req.query

  if (!merchantId) {
    return res.status(401).json({ message: "Unauthorized" })
  }

  if (!sales_channel_id) {
    return res.status(400).json({
      message: "sales_channel_id is required",
    })
  }

  // 🔒 Verify merchant owns this sales channel
  const owns = await pool.query(
    `
    SELECT 1
    FROM merchant_stores ms
    JOIN store s ON s.id = ms.store_id
    WHERE ms.merchant_id = $1
      AND s.default_sales_channel_id = $2
    `,
    [merchantId, sales_channel_id]
  )

  if (owns.rowCount === 0) {
    return res.status(403).json({ message: "Forbidden" })
  }

  // ✅ Fetch ONLY this merchant’s collections
  const { rows } = await pool.query(
    `
    SELECT id, title, handle, description
    FROM merchant_collections
    WHERE sales_channel_id = $1
    ORDER BY created_at DESC
    `,
    [sales_channel_id]
  )

  return res.json({ collections: rows })
}



// import { pool } from "../../../../lib/db"

// export const config = {
//   auth: {
//     actor: "merchant",
//   },
// }

// export async function GET(req, res) {
//   const { sales_channel_id } = req.query

//   if (!sales_channel_id) {
//     return res.status(400).json({
//       message: "sales_channel_id is required",
//     })
//   }

//   const { rows } = await pool.query(
//     `
//     SELECT id, title, handle, description
//     FROM merchant_collections
//     WHERE sales_channel_id = $1
//     ORDER BY created_at DESC
//     `,
//     [sales_channel_id]
//   )

//   return res.json({ collections: rows })
// }



// export const config = {
//   auth: { actor: "merchant" },
// }

// export async function GET(req, res) {
//   const merchantId = req.auth_context?.actor_id

//   if (!merchantId) {
//     return res.status(401).json({ message: "Unauthorized" })
//   }

//   const db = req.scope.resolve("db")

//   const rows = await db.query(
//     `
//     SELECT collection_id
//     FROM merchant_collection_access
//     WHERE merchant_id = $1
//     `,
//     [merchantId]
//   )

//   if (!rows.length) {
//     return res.json({ collections: [] })
//   }

//   const sdk = req.scope.resolve("sdk")

//   const collections = await Promise.all(
//     rows.map((r) =>
//       sdk.store.collection
//         .retrieve(r.collection_id)
//         .then((res) => res.collection)
//     )
//   )

//   return res.json({ collections })
// }
