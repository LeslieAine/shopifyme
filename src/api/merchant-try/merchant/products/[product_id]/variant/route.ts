export const config = {
  auth: {
    actor: "merchant",
  },
}

export async function POST(req, res) {
  const { collection_id } = req.params
  const { product_id, sales_channel_id } = req.body

  if (!product_id || !sales_channel_id) {
    return res.status(400).json({
      message: "product_id and sales_channel_id are required",
    })
  }

  const db = req.scope.resolve("db")

  // Ensure collection belongs to this sales channel
  const owns = await db.query(
    `
    SELECT 1
    FROM merchant_collections
    WHERE id = $1 AND sales_channel_id = $2
    `,
    [collection_id, sales_channel_id]
  )

  if (!owns.length) {
    return res.status(403).json({ message: "Forbidden" })
  }

  await db.query(
    `
    INSERT INTO merchant_collection_products (collection_id, product_id)
    VALUES ($1, $2)
    ON CONFLICT DO NOTHING
    `,
    [collection_id, product_id]
  )

  return res.json({ success: true })
}



// import { Modules } from "@medusajs/framework/utils"

// export const config = {
//   auth: {
//     actor: "merchant",
//   },
// }

// export async function POST(req, res) {
//   const { product_id } = req.params
//   const { price, currency_code, sales_channel_id } = req.body

//   if (!price || !currency_code || !sales_channel_id) {
//     return res.status(400).json({
//       message: "price, currency_code, and sales_channel_id are required",
//     })
//   }

//   const productService = req.scope.resolve(Modules.PRODUCT)

//   // 1️⃣ Create a default variant
//   const [variant] = await productService.createProductVariants([
//     {
//       product_id,
//       title: "Default",
//       prices: [
//         {
//           amount: price,
//           currency_code,
//         },
//       ],
//       sales_channels: [
//         {
//           id: sales_channel_id,
//         },
//       ],
//     },
//   ])

//   // 2️⃣ Publish the product
//   await productService.updateProducts(product_id, {
//     status: "published",
//     sales_channels: [
//         {
//           id: sales_channel_id,
//         },
//     ]
//   })

//   return res.status(201).json({
//     variant,
//   })
// }
