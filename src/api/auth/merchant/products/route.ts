import { Modules } from "@medusajs/framework/utils"
import { linkProductsToSalesChannelWorkflow } from "@medusajs/medusa/core-flows"
// import { Modules } from "@medusajs/framework/utils"

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
   * IMPORTANT:
   * We CANNOT filter by sales_channel_id here (Medusa v2 limitation).
   * This endpoint is used for:
   * - merchant dashboard
   * - deriving collections
   *
   * For now we return ALL products.
   * Sales-channel isolation is enforced elsewhere (storefront + write flow).
   */
  const products = await productService.listProducts(
    {},
    {
      relations: ["collection"],
    }
  )

  return res.json({ products })
}


export async function POST(req, res) {
  const { title, description, sales_channel_id } = req.body

  if (!title) {
    return res.status(400).json({
      message: "Product title is required",
    })
  }

  if (!sales_channel_id) {
    return res.status(400).json({
      message: "sales_channel_id is required",
    })
  }

  const productService = req.scope.resolve(Modules.PRODUCT)

  // 1️⃣ Create product (NO sales_channels here)
  const product = await productService.createProducts({
    title,
    description,
    status: "draft",
  })

  // 2️⃣ Link product to sales channel (THIS IS THE KEY)
  await linkProductsToSalesChannelWorkflow(req.scope).run({
    input: {
      id: sales_channel_id,
      add: [product.id],
    },
  })

  return res.status(201).json({
    product,
  })
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
