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
  const merchantId = req.auth_context.actor_id
  const productId = req.params.id
  const query = req.scope.resolve("query")
  const merchantService = req.scope.resolve("merchant")

  if (!merchantId) {
    throw new MedusaError(MedusaError.Types.UNAUTHORIZED, "Not authenticated")
  }

  const merchant = await merchantService.retrieveMerchant(merchantId)

  if (!merchant.sales_channel_id) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Merchant has no sales channel"
    )
  }

  const { data: productCheck } = await query.graph({
    entity: "product",
    fields: ["id", "sales_channels.id"],
    filters: { id: productId },
  })

  const product = productCheck?.[0]
  const belongsToMerchant = !!product?.sales_channels?.some(
    (sc: any) => sc.id === merchant.sales_channel_id
  )

  if (!belongsToMerchant) {
    throw new MedusaError(
      MedusaError.Types.NOT_ALLOWED,
      "Product does not belong to merchant sales channel"
    )
  }

  const { data: options } = await query.graph({
    entity: "product_option",
    fields: ["id", "title", "values.value"],
    filters: { product_id: productId },
  })

  const realOptions = options.filter((o: any) => o.title !== "Default")

  if (realOptions.length === 0) {
    return res.json({ variants: [] })
  }

  const { data: existingVariants } = await query.graph({
    entity: "product_variant",
    fields: ["id", "title"],
    filters: { product_id: productId },
  })

  const hasRealVariants = existingVariants.some((v: any) => v.title !== "Default")

  if (hasRealVariants) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Variants already exist. Delete them before regenerating."
    )
  }

  const combinations = realOptions.reduce<string[][]>((acc, option: any) => {
    const values = option.values.map((v: any) => v.value)
    if (acc.length === 0) return values.map((v: string) => [v])
    return acc.flatMap((prev) => values.map((v: string) => [...prev, v]))
  }, [])

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
      manage_inventory: true,
      allow_backorder: false,
    }
  })

  const { result } = await createProductVariantsWorkflow(req.scope).run({
    input: { product_variants: variants },
  })

  res.json({ variants: result })
}



// //src/api/merchant/products/[id]/variants/generate/route.ts
// import {
//   AuthenticatedMedusaRequest,
//   MedusaResponse,
// } from "@medusajs/framework/http"
// import { MedusaError } from "@medusajs/framework/utils"
// import { createProductVariantsWorkflow } from "@medusajs/medusa/core-flows"

// export async function POST(
//   req: AuthenticatedMedusaRequest,
//   res: MedusaResponse
// ) {
//   const productId = req.params.id
//   const query = req.scope.resolve("query")

//   // 1️⃣ Load options
//   const { data: options } = await query.graph({
//     entity: "product_option",
//     fields: ["id", "title", "values.value"],
//     filters: { product_id: productId },
//   })

//   const realOptions = options.filter(
//     (o) => o.title !== "Default"
//   )

//   if (realOptions.length === 0) {
//     return res.json({ variants: [] })
//   }

//   // 2️⃣ Check existing non-default variants
//   const { data: existingVariants } = await query.graph({
//     entity: "product_variant",
//     fields: ["id", "title"],
//     filters: { product_id: productId },
//   })

//   const hasRealVariants = existingVariants.some(
//     (v) => v.title !== "Default"
//   )

//   if (hasRealVariants) {
//     throw new MedusaError(
//       MedusaError.Types.INVALID_DATA,
//       "Variants already exist. Delete them before regenerating."
//     )
//   }

//   // 3️⃣ Cartesian product
//   const combinations = realOptions.reduce<string[][]>(
//     (acc, option) => {
//       const values = option.values.map((v) => v.value)
//       if (acc.length === 0) return values.map((v) => [v])
//       return acc.flatMap((prev) =>
//         values.map((v) => [...prev, v])
//       )
//     },
//     []
//   )

//   // 4️⃣ Build variants
//   const variants = combinations.map((combo) => {
//     const optionsMap: Record<string, string> = {}
//     combo.forEach((value, idx) => {
//       optionsMap[realOptions[idx].title] = value
//     })

//     return {
//       product_id: productId,
//       title: combo.join(" / "),
//       sku: `${productId}-${combo.join("-")}`.toLowerCase(),
//       options: optionsMap,
//     }
//   })

//   const { result } = await createProductVariantsWorkflow(req.scope).run({
//     input: {
//       product_variants: variants,
//     },
//   })

//   res.json({ variants: result })
// }
