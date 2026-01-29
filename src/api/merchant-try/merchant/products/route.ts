import fetch from "node-fetch"
import { Modules } from "@medusajs/framework/utils"
import { linkProductsToSalesChannelWorkflow } from "@medusajs/medusa/core-flows"

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

  const storeRes = await fetch(
    `${process.env.MEDUSA_BACKEND_URL}/store/products?sales_channel_id=${sales_channel_id}&fields=id,title,collection_id`,
    {
      headers: {
        "x-publishable-api-key": process.env.MEDUSA_PUBLISHABLE_KEY,
      },
    }
  )

  const data = await storeRes.json()

  if (!storeRes.ok) {
    return res.status(storeRes.status).json(data)
  }

  return res.json({
    products: data.products || [],
  })
}


export async function POST(req, res) {
  const { title, description, sales_channel_id } = req.body

  if (!title || !sales_channel_id) {
    return res.status(400).json({
      message: "title and sales_channel_id are required",
    })
  }

  const productService = req.scope.resolve(Modules.PRODUCT)

  const product = await productService.createProducts({
    title,
    description,
    status: "draft",
  })

  await linkProductsToSalesChannelWorkflow(req.scope).run({
    input: {
      id: sales_channel_id,
      add: [product.id],
    },
  })

  return res.status(201).json({ product })
}



// import { Modules } from "@medusajs/framework/utils"

// export const config = {
//   auth: {
//     actor: "merchant",
//   },
// }

// export async function POST(req, res) {
//   const { title, description, sales_channel_id } = req.body

//   if (!title) {
//     return res.status(400).json({
//       message: "Product title is required",
//     })
//   }

//   if (!sales_channel_id) {
//     return res.status(400).json({
//       message: "sales_channel_id is required",
//     })
//   }

//   // At this point, auth is enforced by Medusa
//   // req.user WILL exist and be a merchant
//   const user = req.user

//   const productService = req.scope.resolve(Modules.PRODUCT)

//   const product = await productService.createProducts({
//     title,
//     description,
//     status: "draft",
//     sales_channels: [
//       {
//         id: sales_channel_id,
//       },
//     ],
//   })

//   return res.status(201).json({
//     product,
//   })
// }
