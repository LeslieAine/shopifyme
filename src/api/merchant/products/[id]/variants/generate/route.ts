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
