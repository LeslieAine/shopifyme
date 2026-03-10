import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError, Modules } from "@medusajs/framework/utils"
import {
  linkProductsToSalesChannelWorkflow,
  createProductVariantsWorkflow,
  createProductOptionsWorkflow,
} from "@medusajs/medusa/core-flows"

type Body = {
  title: string
  description?: string
  price: number
  shipping_profile_id?: string
}

export async function POST(
  req: AuthenticatedMedusaRequest<Body>,
  res: MedusaResponse
) {
  const merchantService = req.scope.resolve("merchant")
  const productService = req.scope.resolve("product")
  const query = req.scope.resolve("query")
  const link = req.scope.resolve("link")

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

  const { title, description, price, shipping_profile_id } = req.body

  if (!title || price == null) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "title and price are required"
    )
  }

  // --------------------------------------------
  // Determine Shipping Profile (Shopify-style)
  // --------------------------------------------

  const profileToUse =
    shipping_profile_id || merchant.default_shipping_profile_id

  if (!profileToUse) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "No shipping profile specified and merchant has no default profile"
    )
  }

  // Validate shipping profile exists
  const { data: profileCheck } = await query.graph({
    entity: "shipping_profile",
    fields: ["id"],
    filters: { id: profileToUse },
  })

  if (!profileCheck.length) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Invalid shipping profile"
    )
  }

  // --------------------------------------------
  // 1️⃣ Create Product
  // --------------------------------------------

  const product = await productService.createProducts({
    title,
    description,
    status: "published",
  })

  // --------------------------------------------
  // 2️⃣ Create Default Product Option
  // --------------------------------------------

  await createProductOptionsWorkflow(req.scope).run({
    input: {
      product_options: [
        {
          product_id: product.id,
          title: "Default",
          values: ["Default"],
        },
      ],
    },
  })

  // --------------------------------------------
  // 3️⃣ Link Product to Merchant Sales Channel
  // --------------------------------------------

  await linkProductsToSalesChannelWorkflow(req.scope).run({
    input: {
      id: merchant.sales_channel_id,
      add: [product.id],
    },
  })

  // --------------------------------------------
  // 4️⃣ Link Product to Shipping Profile
  // --------------------------------------------

  await link.create({
    [Modules.PRODUCT]: {
      product_id: product.id,
    },
    [Modules.FULFILLMENT]: {
      shipping_profile_id: profileToUse,
    },
  })

  // --------------------------------------------
  // 5️⃣ Create Default Variant
  // --------------------------------------------

  await createProductVariantsWorkflow(req.scope).run({
    input: {
      product_variants: [
        {
          product_id: product.id,
          title: "Default",
          sku: `${product.id}-default`,
          manage_inventory: true,
          allow_backorder: false,
          options: {
            Default: "Default",
          },
          prices: [
            {
              amount: Math.round(price),
              currency_code: "usd",
            },
          ],
        },
      ],
    },
  })

  return res.status(201).json({ product })
}



// // src/api/merchant/products/route.ts
// import {
//     AuthenticatedMedusaRequest,
//     MedusaResponse,
// } from "@medusajs/framework/http"
// import { MedusaError, Modules } from "@medusajs/framework/utils"
// import {
//     linkProductsToSalesChannelWorkflow,
//     createProductVariantsWorkflow,
//     upsertVariantPricesWorkflow,
//     createProductOptionsWorkflow,
// } from "@medusajs/medusa/core-flows"

// type Body = {
//     title: string
//     description?: string
//     price: number
// }

// export async function POST(
//     req: AuthenticatedMedusaRequest<Body>,
//     res: MedusaResponse
// ) {
//     const merchantService = req.scope.resolve("merchant")
//     const productService = req.scope.resolve("product")

//     const merchantId = req.auth_context.actor_id
//     if (!merchantId) {
//         throw new MedusaError(
//             MedusaError.Types.UNAUTHORIZED,
//             "Not authenticated as merchant"
//         )
//     }

//     const merchant = await merchantService.retrieveMerchant(merchantId)

//     if (!merchant.default_shipping_profile_id) {
//   throw new MedusaError(
//     MedusaError.Types.INVALID_DATA,
//     "Merchant has no default shipping profile configured"
//   )
// }


//     if (!merchant.sales_channel_id) {
//         throw new MedusaError(
//             MedusaError.Types.INVALID_DATA,
//             "Merchant has no sales channel"
//         )
//     }

//     const { title, description, price } = req.body

//     if (!title || price == null) {
//         throw new MedusaError(
//             MedusaError.Types.INVALID_DATA,
//             "title and price are required"
//         )
//     }

//     // 1️⃣ Create product
//     const product = await productService.createProducts({
//         title,
//         description,
//         status: "published",
//     })

//     await createProductOptionsWorkflow(req.scope).run({
//         input: {
//             product_options: [
//                 {
//                     product_id: product.id,
//                     title: "Default",
//                     values: ["Default"],
//                 },
//             ],
//         },
//     })
//     // 2️⃣ Link product to merchant sales channel
//     await linkProductsToSalesChannelWorkflow(req.scope).run({
//         input: {
//             id: merchant.sales_channel_id,
//             add: [product.id],
//         },
//     })

//     const link = req.scope.resolve("link")

// await link.create({
//   [Modules.PRODUCT]: {
//     product_id: product.id,
//   },
//   [Modules.FULFILLMENT]: {
//     shipping_profile_id: merchant.default_shipping_profile_id,
//   },
// })


//     // 3️⃣ Create DEFAULT variant (CORRECT INPUT SHAPE)
//     const { result: variants } =
//         await createProductVariantsWorkflow(req.scope).run({
//             input: {
//                 product_variants: [
//                     {
//                         product_id: product.id,
//                         title: "Default",
//                         sku: `${product.id}-default`,
//                         manage_inventory: true,
//                         allow_backorder: false,
//                         options: {
//                             Default: "Default",
//                         },
//                         prices: [
//                             {
//                                 amount: Math.round(price),
//                                 currency_code: "usd",
//                             },
//                         ],
//                     },
//                 ],
//             },
//         })

//     res.status(201).json({ product })
// }
