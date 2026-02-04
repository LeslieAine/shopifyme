//src/api/merchant/products/[id]/options/route.ts
import {
    AuthenticatedMedusaRequest,
    MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import {
    createProductOptionsWorkflow,
    deleteProductOptionsWorkflow,
    deleteProductVariantsWorkflow,
} from "@medusajs/medusa/core-flows"

export async function POST(
    req: AuthenticatedMedusaRequest<{
        options: { title: string; values: string[] }[]
    }>,
    res: MedusaResponse
) {
    const productId = req.params.id
    const merchantId = req.auth_context.actor_id

    if (!merchantId) {
        throw new MedusaError(
            MedusaError.Types.UNAUTHORIZED,
            "Not authenticated"
        )
    }

    const query = req.scope.resolve("query")

    // 1️⃣ Load existing options
    const { data: existingOptions } = await query.graph({
        entity: "product_option",
        fields: ["id", "title"],
        filters: { product_id: productId },
    })

    const defaultOption = existingOptions.find(
        (o) => o.title === "Default"
    )

    // 2️⃣ Create real options
    //   const { result } = await createProductOptionsWorkflow(req.scope).run({
    //     input: {
    //       product_options: req.body.options,
    //     },
    //   })
    const { result } = await createProductOptionsWorkflow(req.scope).run({
        input: {
            product_options: req.body.options.map((opt) => ({
                product_id: productId,
                title: opt.title,
                values: opt.values,
            })),
        },
    })


    // 3️⃣ Remove Default option + variant IF it exists
    if (defaultOption) {
        // delete Default variants
        const { data: variants } = await query.graph({
            entity: "product_variant",
            fields: ["id"],
            filters: { product_id: productId },
        })

        const defaultVariants = variants.filter(
            (v) => v.title === "Default"
        )

        if (defaultVariants.length) {
            await deleteProductVariantsWorkflow(req.scope).run({
                input: {
                    ids: defaultVariants.map((v) => v.id),
                },
            })
        }

        await deleteProductOptionsWorkflow(req.scope).run({
            input: {
                ids: [defaultOption.id],
            },
        })
    }

    res.json({ options: result })
}

export async function GET(
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) {
  const productId = req.params.id
  const merchantId = req.auth_context.actor_id

  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated as merchant"
    )
  }

  const query = req.scope.resolve("query")

  /**
   * Load product options with values
   * This is intentionally explicit – Medusa does NOT auto-expand this
   */
  const { data: options } = await query.graph({
    entity: "product_option",
    fields: [
      "id",
      "title",
      "product_id",
      "values.id",
      "values.value",
    ],
    filters: {
      product_id: productId,
    },
  })

  res.json({ options })
}


// import {
//   AuthenticatedMedusaRequest,
//   MedusaResponse,
// } from "@medusajs/framework/http"
// import { MedusaError } from "@medusajs/framework/utils"
// import { createProductOptionsWorkflow } from "@medusajs/medusa/core-flows"

// type Body = {
//   options: {
//     title: string
//     values: string[]
//   }[]
// }

// export async function POST(
//   req: AuthenticatedMedusaRequest<Body>,
//   res: MedusaResponse
// ) {
//   const merchantId = req.auth_context.actor_id
//   const productId = req.params.id
//   const { options } = req.body

//   if (!merchantId) {
//     throw new MedusaError(
//       MedusaError.Types.UNAUTHORIZED,
//       "Not authenticated as merchant"
//     )
//   }

//   if (!Array.isArray(options) || options.length === 0) {
//     throw new MedusaError(
//       MedusaError.Types.INVALID_DATA,
//       "Options are required"
//     )
//   }

//   await createProductOptionsWorkflow(req.scope).run({
//     input: {
//       product_options: options.map((opt) => ({
//         title: opt.title,
//         values: opt.values,
//         product_id: productId, //OPTIONAL but VALID
//       })),
//     },
//   })

//   res.json({ ok: true })
// }
