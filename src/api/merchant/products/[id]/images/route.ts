// import {
//   AuthenticatedMedusaRequest,
//   MedusaResponse,
// } from "@medusajs/framework/http"
// import { updateProductsWorkflow } from "@medusajs/medusa/core-flows"

// type Body = {
//   images: {
//     url: string
//     rank?: number
//   }[]
// }

// export async function POST(
//   req: AuthenticatedMedusaRequest<Body>,
//   res: MedusaResponse
// ) {
//   const productId = req.params.id
//   const { images } = req.body

//   await updateProductsWorkflow(req.scope).run({
//     input: {
//       products: [
//         {
//           id: productId,
//           images,
//           thumbnail: images[0]?.url,
//         },
//       ],
//     },
//   })

//   res.json({ ok: true })
// }


import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { updateProductsWorkflow } from "@medusajs/medusa/core-flows"

type Body = {
  images: { url: string; rank?: number }[]
  thumbnail?: string
}

export async function POST(
  req: AuthenticatedMedusaRequest<Body>,
  res: MedusaResponse
) {
  const merchantId = req.auth_context.actor_id
  const productId = req.params.id

  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated"
    )
  }

  await updateProductsWorkflow(req.scope).run({
    input: {
      products: [
        {
          id: productId,
          images: req.body.images,
          thumbnail: req.body.thumbnail,
        },
      ],
    },
  })

  res.json({ ok: true })
}
