import { Modules } from "@medusajs/framework/utils"

export const config = {
  auth: {
    actor: "merchant",
  },
}

export async function POST(req, res) {
  const { product_id } = req.params
  const { price, currency_code } = req.body

  if (!price || !currency_code) {
    return res.status(400).json({
      message: "price and currency_code are required",
    })
  }

  const productService = req.scope.resolve(Modules.PRODUCT)

  // 1) create default variant + price
  await productService.createProductVariants([
    {
      product_id,
      title: "Default",
      prices: [{ amount: price, currency_code }],
    },
  ])

  // 2) publish product
  await productService.updateProducts(product_id, {
    status: "published",
  })

  return res.status(201).json({ success: true })
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
