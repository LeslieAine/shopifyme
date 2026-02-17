import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import {
  createInventoryLevelsWorkflow,
  updateInventoryLevelsWorkflow,
} from "@medusajs/medusa/core-flows"

type Body = {
  variant_id: string
  stock_location_id: string
  quantity: number
}

export async function POST(
  req: AuthenticatedMedusaRequest<Body>,
  res: MedusaResponse
) {
  const merchantId = req.auth_context.actor_id

  if (!merchantId) {
    throw new MedusaError(
      MedusaError.Types.UNAUTHORIZED,
      "Not authenticated"
    )
  }

  const { variant_id, stock_location_id, quantity } = req.body

  if (!variant_id || !stock_location_id || quantity == null) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "variant_id, stock_location_id and quantity are required"
    )
  }

  const query = req.scope.resolve("query")

  // 1️⃣ Get inventory item via variant link
const { data: variants } = await query.graph({
  entity: "variant",
  fields: [
    "id",
    "inventory_items.inventory_item_id"
  ],
  filters: {
    id: variant_id,
  },
})

const inventoryItemId =
  variants?.[0]?.inventory_items?.[0]?.inventory_item_id

if (!inventoryItemId) {
  throw new MedusaError(
    MedusaError.Types.INVALID_DATA,
    "Variant has no inventory item"
  )
}



  if (!inventoryItemId) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Variant has no inventory item"
    )
  }

  // 2️⃣ Check if inventory level already exists
  const { data: levels } = await query.graph({
    entity: "inventory_level",
    fields: ["id", "inventory_item_id", "location_id"],
    filters: {
      inventory_item_id: inventoryItemId,
      location_id: stock_location_id,
    },
  })

  if (levels.length === 0) {
    // Create level
    await createInventoryLevelsWorkflow(req.scope).run({
      input: {
        inventory_levels: [
          {
            inventory_item_id: inventoryItemId,
            location_id: stock_location_id,
            stocked_quantity: quantity,
          },
        ],
      },
    })
  } else {
    // Update level
    await updateInventoryLevelsWorkflow(req.scope).run({
      input: {
        updates: [
          {
            id: levels[0].id,
            inventory_item_id: inventoryItemId,
            location_id: stock_location_id,
            stocked_quantity: quantity,
          },
        ],
      },
    })
  }

  res.json({ ok: true })
}
