import { model } from "@medusajs/framework/utils"

export const MerchantStockLocation = model.define("merchant_stock_location", {
  id: model.id().primaryKey(),

  merchant_id: model.text().index(),

  stock_location_id: model.text().unique(),
})
