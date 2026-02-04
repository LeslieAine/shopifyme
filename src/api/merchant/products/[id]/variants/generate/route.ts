// import {
//   AuthenticatedMedusaRequest,
//   MedusaResponse,
// } from "@medusajs/framework/http"
// import { MedusaError } from "@medusajs/framework/utils"
// import {
//   createProductVariantsWorkflow,
//   upsertVariantPricesWorkflow,
// } from "@medusajs/medusa/core-flows"
// import type { CreateProductVariantDTO } from "@medusajs/types"

// type GenerateVariantsBody = {
//   price?: number
// }

// export async function POST(
//   req: AuthenticatedMedusaRequest<GenerateVariantsBody>,
//   res: MedusaResponse
// ) {
//   const merchantId = req.auth_context.actor_id
//   const productId = req.params.id

//   if (!merchantId) {
//     throw new MedusaError(
//       MedusaError.Types.UNAUTHORIZED,
//       "Not authenticated as merchant"
//     )
//   }

//   const productService = req.scope.resolve("product")

//   /**
//    * 1️⃣ Load product with options + variants
//    */
//   const product = await productService.retrieveProduct(productId, {
//     relations: [
//       "options",
//       "options.values",
//       "variants",
//       "variants.options",
//       "variants.options.option",
//     ],
//   })

//   if (!product.options?.length) {
//     throw new MedusaError(
//       MedusaError.Types.INVALID_DATA,
//       "Product has no options"
//     )
//   }

//   /**
//    * 2️⃣ Cartesian product of option values
//    */
//   const optionMatrix = product.options.map((opt) =>
//     opt.values.map((v) => ({
//       optionTitle: opt.title,
//       value: v.value,
//     }))
//   )

//   function cartesian<T>(arrays: T[][]): T[][] {
//     return arrays.reduce<T[][]>(
//       (acc, curr) =>
//         acc.flatMap((a) => curr.map((b) => [...a, b])),
//       [[]]
//     )
//   }

//   const combinations = cartesian(optionMatrix)

//   /**
//    * 3️⃣ Existing variant signatures
//    */
//   const existingSignatures = new Set(
//     product.variants.map((v) =>
//       v.options
//         .filter((o) => o.option)
//         .map((o) => `${o.option!.title}:${o.value}`)
//         .sort()
//         .join("|")
//     )
//   )

//   /**
//    * 4️⃣ Build variants safely (NO nulls)
//    */
//   const variantsToCreate: CreateProductVariantDTO[] = []

//   for (const combo of combinations) {
//     const signature = combo
//       .map((c) => `${c.optionTitle}:${c.value}`)
//       .sort()
//       .join("|")

//     if (existingSignatures.has(signature)) {
//       continue
//     }

//     variantsToCreate.push({
//       product_id: productId,
//       title: combo.map((c) => c.value).join(" / "),
//       sku:
//         product.handle +
//         "-" +
//         combo.map((c) => c.value.toLowerCase()).join("-"),
//       options: combo.reduce<Record<string, string>>((acc, c) => {
//         acc[c.optionTitle] = c.value
//         return acc
//       }, {}),
//     })
//   }

//   if (!variantsToCreate.length) {
//     return res.json({ variants: [] })
//   }

//   /**
//    * 5️⃣ Create variants
//    */
//   const { result: variants } = await createProductVariantsWorkflow(
//     req.scope
//   ).run({
//     input: {
//       product_variants: variantsToCreate,
//     },
//   })

//   /**
//    * 6️⃣ Apply base price (Shopify-style)
//    * Use first existing variant’s price OR require frontend input
//    */
//   const basePrice = req.body?.price
//     ? Math.round(Number(req.body.price) * 100)
//     : null

//   if (basePrice !== null) {
//     await upsertVariantPricesWorkflow(req.scope).run({
//       input: {
//         variantPrices: variants.map((v) => ({
//           variant_id: v.id,
//           product_id: productId,
//           prices: [
//             {
//               amount: basePrice,
//               currency_code: "usd",
//             },
//           ],
//         })),
//         previousVariantIds: [],
//       },
//     })
//   }

//   res.json({ variants })
// }


//src/api/merchant/products/[id]/variants/generate/route.ts
import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { createProductVariantsWorkflow } from "@medusajs/medusa/core-flows"

export async function POST(
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) {
  const productId = req.params.id
  const query = req.scope.resolve("query")

  // 1️⃣ Load options
  const { data: options } = await query.graph({
    entity: "product_option",
    fields: ["id", "title", "values.value"],
    filters: { product_id: productId },
  })

  const realOptions = options.filter(
    (o) => o.title !== "Default"
  )

  if (realOptions.length === 0) {
    return res.json({ variants: [] })
  }

  // 2️⃣ Check existing non-default variants
  const { data: existingVariants } = await query.graph({
    entity: "product_variant",
    fields: ["id", "title"],
    filters: { product_id: productId },
  })

  const hasRealVariants = existingVariants.some(
    (v) => v.title !== "Default"
  )

  if (hasRealVariants) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Variants already exist. Delete them before regenerating."
    )
  }

  // 3️⃣ Cartesian product
  const combinations = realOptions.reduce<string[][]>(
    (acc, option) => {
      const values = option.values.map((v) => v.value)
      if (acc.length === 0) return values.map((v) => [v])
      return acc.flatMap((prev) =>
        values.map((v) => [...prev, v])
      )
    },
    []
  )

  // 4️⃣ Build variants
  const variants = combinations.map((combo) => {
    const optionsMap: Record<string, string> = {}
    combo.forEach((value, idx) => {
      optionsMap[realOptions[idx].title] = value
    })

    return {
      product_id: productId,
      title: combo.join(" / "),
      sku: `${productId}-${combo.join("-")}`.toLowerCase(),
      options: optionsMap,
    }
  })

  const { result } = await createProductVariantsWorkflow(req.scope).run({
    input: {
      product_variants: variants,
    },
  })

  res.json({ variants: result })
}
