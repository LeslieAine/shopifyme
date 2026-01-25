import { pool } from "../../../../../lib/db"

export const config = {
  auth: {
    actor: "merchant",
  },
}

export async function POST(req, res) {
  const { title, description, sales_channel_id } = req.body

  if (!title || !sales_channel_id) {
    return res.status(400).json({
      message: "title and sales_channel_id are required",
    })
  }

  const handle = title
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "")

  const { rows } = await pool.query(
    `
    INSERT INTO merchant_collections
      (sales_channel_id, title, handle, description)
    VALUES ($1, $2, $3, $4)
    RETURNING id, title, handle, description
    `,
    [sales_channel_id, title, handle, description || null]
  )

  return res.status(201).json({ collection: rows[0] })
}


// import { createCollectionsWorkflow } from "@medusajs/medusa/core-flows"

// export const config = {
//   auth: {
//     actor: "merchant",
//   },
// }

// export async function POST(req, res) {
//   const { title } = req.body

//   if (!title) {
//     return res.status(400).json({
//       message: "title is required",
//     })
//   }

//   const { result } = await createCollectionsWorkflow(req.scope).run({
//     input: {
//       collections: [
//         {
//           title,
//         },
//       ],
//     },
//   })

//   return res.status(201).json({
//     collection: result[0],
//   })
// }
