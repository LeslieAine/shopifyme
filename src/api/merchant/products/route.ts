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

//   const merchantId = req.auth_context.actor_id
//   if (!merchantId) {
//     throw new MedusaError(
//       MedusaError.Types.UNAUTHORIZED,
//       "Not authenticated as merchant"
//     )
//   }

//   const merchant = await merchantService.retrieveMerchant(merchantId)

//   if (!merchant.sales_channel_id) {
//     throw new MedusaError(
//       MedusaError.Types.INVALID_DATA,
//       "Merchant has no sales channel"
//     )
//   }

//   // 1️⃣ Create product (draft by default)
//   const product = await productService.createProducts({
//     title: req.body.title,
//     description: req.body.description,
//     status: "published",
//   })

//   // 2️⃣ Link product → merchant’s PRIVATE sales channel
//   await linkProductsToSalesChannelWorkflow(req.scope).run({
//     input: {
//       id: merchant.sales_channel_id,
//       add: [product.id],
//     },
//   })

//   res.status(201).json({ product })
// }
import {
    AuthenticatedMedusaRequest,
    MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import {
    linkProductsToSalesChannelWorkflow,
    createProductVariantsWorkflow,
    upsertVariantPricesWorkflow,
    createProductOptionsWorkflow,
} from "@medusajs/medusa/core-flows"

type Body = {
    title: string
    description?: string
    price: number
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

    const { title, description, price } = req.body

    if (!title || price == null) {
        throw new MedusaError(
            MedusaError.Types.INVALID_DATA,
            "title and price are required"
        )
    }

    // 1️⃣ Create product
    const product = await productService.createProducts({
        title,
        description,
        status: "published",
    })

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
    // 2️⃣ Link product to merchant sales channel
    await linkProductsToSalesChannelWorkflow(req.scope).run({
        input: {
            id: merchant.sales_channel_id,
            add: [product.id],
        },
    })

    // 3️⃣ Create DEFAULT variant (CORRECT INPUT SHAPE)
    const { result: variants } =
  await createProductVariantsWorkflow(req.scope).run({
    input: {
      product_variants: [
        {
          product_id: product.id,
          title: "Default",
          sku: `${product.id}-default`,
          options: {
            Default: "Default",
          },
          prices: [
            {
              amount: Math.round(price * 100),
              currency_code: "usd",
            },
          ],
        },
      ],
    },
  })


    // 4️⃣ Attach price to variant (CORRECT INPUT SHAPE)
    // await upsertVariantPricesWorkflow(req.scope).run({
    //     input: {
    //         variantPrices: [
    //             {
    //                 variant_id: variant.id,
    //                 product_id: product.id,
    //                 prices: [
    //                     {
    //                         amount: Math.round(price * 100),
    //                         currency_code: "usd",
    //                     },
    //                 ],
    //             },
    //         ],
    //         previousVariantIds: [], //REQUIRED BY TYPE
    //     },
    // })


    res.status(201).json({ product })
}
