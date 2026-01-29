
// import {
//   AuthenticatedMedusaRequest,
//   MedusaResponse,
// } from "@medusajs/framework/http"
// import { MedusaError } from "@medusajs/framework/utils"
// import { linkProductsToSalesChannelWorkflow } from "@medusajs/medusa/core-flows"

// type Body = {
//   title: string
//   description?: string
// }

// export async function POST(
//   req: AuthenticatedMedusaRequest<Body>,
//   res: MedusaResponse
// ) {
//   const merchantService = req.scope.resolve("merchant")
//   const productService = req.scope.resolve("product")

//   const merchant = await merchantService.retrieveMerchant(
//     req.auth_context.actor_id
//   )

//   if (!merchant.sales_channel_id) {
//     throw new MedusaError(
//       MedusaError.Types.INVALID_DATA,
//       "Merchant has no sales channel"
//     )
//   }

//   // 1️⃣ Create product (pure product DTO)
//   const [product] = await productService.createProducts([
//     {
//       title: req.body.title,
//       description: req.body.description,
//     },
//   ])

//   // 2️⃣ Add product to merchant's sales channel (DOC-CORRECT)
//   await linkProductsToSalesChannelWorkflow(req.scope).run({
//     input: {
//       id: merchant.sales_channel_id, // sales channel ID
//       add: [product.id],              // product IDs to add
//     },
//   })

//   res.status(201).json({ product })
// }

// export async function GET(
//   req: AuthenticatedMedusaRequest,
//   res: MedusaResponse
// ) {
//   const merchantService = req.scope.resolve("merchant")
//   const query = req.scope.resolve("query")

//   const merchant = await merchantService.retrieveMerchant(
//     req.auth_context.actor_id
//   )

//   if (!merchant.sales_channel_id) {
//     throw new MedusaError(
//       MedusaError.Types.INVALID_DATA,
//       "Merchant has no sales channel"
//     )
//   }

//   const { data: products } = await query.graph({
//     entity: "product",
//     fields: ["*"],
//     filters: {
//       sales_channels: {
//         id: merchant.sales_channel_id,
//       },
//     },
//   })

//   res.json({ products })
// }



// import {
//   AuthenticatedMedusaRequest,
//   MedusaResponse,
// } from "@medusajs/framework/http"
// import { MedusaError } from "@medusajs/framework/utils"
// import { linkProductsToSalesChannelWorkflow } from "@medusajs/medusa/core-flows"

// /* =========================
//    CREATE PRODUCT (POST)
//    ========================= */

// type CreateBody = {
//   title: string
//   description?: string
// }

// export async function POST(
//   req: AuthenticatedMedusaRequest<CreateBody>,
//   res: MedusaResponse
// ) {
//   const merchantService = req.scope.resolve("merchant")
//   const productService = req.scope.resolve("product")

//   const merchant = await merchantService.retrieveMerchant(
//     req.auth_context.actor_id
//   )

//   if (!merchant.sales_channel_id) {
//     throw new MedusaError(
//       MedusaError.Types.INVALID_DATA,
//       "Merchant has no sales channel"
//     )
//   }

//   // 1️⃣ create product
//   const [product] = await productService.createProducts([
//     {
//       title: req.body.title,
//       description: req.body.description,
//     },
//   ])

//   // 2️⃣ link to merchant sales channel (DOC-CORRECT)
//   await linkProductsToSalesChannelWorkflow(req.scope).run({
//     input: {
//       id: merchant.sales_channel_id,
//       add: [product.id],
//     },
//   })

//   res.status(201).json({ product })
// }

// /* =========================
//    LIST PRODUCTS (GET)
//    ========================= */

// export async function GET(
//   req: AuthenticatedMedusaRequest,
//   res: MedusaResponse
// ) {
//   const merchantService = req.scope.resolve("merchant")
//   const query = req.scope.resolve("query")

//   const merchant = await merchantService.retrieveMerchant(
//     req.auth_context.actor_id
//   )

//   if (!merchant.sales_channel_id) {
//     throw new MedusaError(
//       MedusaError.Types.INVALID_DATA,
//       "Merchant has no sales channel"
//     )
//   }

//   const { data } = await query.graph(
//     {
//       entity: "sales_channel",
//       fields: [
//         "id",
//         "products.id",
//         "products.title",
//         "products.handle",
//         "products.description",
//         "products.status",
//         "products.created_at",
//       ],
//       filters: {
//         id: merchant.sales_channel_id,
//       },
//     },
//     { throwIfKeyNotFound: true }
//   )

//   // 🔑 Graph results are NOT typed — narrow manually
//   const salesChannel = data[0] as unknown as {
//     id: string
//     products?: any[]
//   }

//   res.json({
//     products: salesChannel.products ?? [],
//   })
// }

import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { linkProductsToSalesChannelWorkflow } from "@medusajs/medusa/core-flows"

type Body = {
  title: string
  description?: string
}

export async function POST(
  req: AuthenticatedMedusaRequest<Body>,
  res: MedusaResponse
) {
  const merchantService = req.scope.resolve("merchant")
  const productService = req.scope.resolve("product")

  const merchantId = req.auth_context.actor_id
  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated as merchant"
    )
  }

  const merchant = await merchantService.retrieveMerchant(merchantId)

  if (!merchant.sales_channel_id) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Merchant has no sales channel"
    )
  }

  // 1️⃣ Create product (draft by default)
  const product = await productService.createProducts({
    title: req.body.title,
    description: req.body.description,
    status: "published",
  })

  // 2️⃣ Link product → merchant’s PRIVATE sales channel
  await linkProductsToSalesChannelWorkflow(req.scope).run({
    input: {
      id: merchant.sales_channel_id,
      add: [product.id],
    },
  })

  res.status(201).json({ product })
}
