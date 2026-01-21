import { model } from "@medusajs/framework/utils"

const Merchant = model.define("merchant", {
  id: model.id().primaryKey(),
  email: model.text().unique(),
  store_id: model.text().nullable(),
  sales_channel_id: model.text().nullable(),
  status: model.enum(["pending", "active"]).default("pending"),
})

export default Merchant
