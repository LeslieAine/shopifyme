import type {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"

export async function GET(
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) {
  const query = req.scope.resolve("query")
  const merchantId = req.auth_context.actor_id

  const {
    data: [merchant],
  } = await query.graph(
    {
      entity: "merchant",
      fields: ["*"],
      filters: {
        id: merchantId,
      },
    },
    {
      throwIfKeyNotFound: true,
    }
  )

  res.json({ merchant })
}
