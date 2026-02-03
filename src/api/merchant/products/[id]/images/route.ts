import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { updateProductsWorkflow } from "@medusajs/medusa/core-flows"

type Body = {
  images: {
    url: string
    rank?: number
  }[]
}

export async function POST(
  req: AuthenticatedMedusaRequest<Body>,
  res: MedusaResponse
) {
  const productId = req.params.id
  const { images } = req.body

  await updateProductsWorkflow(req.scope).run({
    input: {
      products: [
        {
          id: productId,
          images,
          thumbnail: images[0]?.url,
        },
      ],
    },
  })

  res.json({ ok: true })
}
