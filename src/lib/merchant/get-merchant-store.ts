import { MedusaError } from "@medusajs/framework/utils"

export async function getMerchantStoreId(
  scope: any,
  merchantId: string
): Promise<string> {
  const query = scope.resolve("query")

  const {
    data: [merchant],
  } = await query.graph(
    {
      entity: "merchant",
      fields: ["id", "store_id"],
      filters: {
        id: merchantId,
      },
    },
    {
      throwIfKeyNotFound: true,
    }
  )

  if (!merchant.store_id) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Merchant does not have an associated store"
    )
  }

  return merchant.store_id
}
