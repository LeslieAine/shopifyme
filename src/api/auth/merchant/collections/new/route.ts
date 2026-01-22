import { createCollectionsWorkflow } from "@medusajs/medusa/core-flows"

export const config = {
  auth: {
    actor: "merchant",
  },
}

export async function POST(req, res) {
  const { title } = req.body

  if (!title) {
    return res.status(400).json({
      message: "title is required",
    })
  }

  const { result } = await createCollectionsWorkflow(req.scope).run({
    input: {
      collections: [
        {
          title,
        },
      ],
    },
  })

  return res.status(201).json({
    collection: result[0],
  })
}
