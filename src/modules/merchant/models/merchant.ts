import { model } from "@medusajs/framework/utils"

const Merchant = model.define("merchant", {
  id: model.id().primaryKey(),
  email: model.text().unique(),
  status: model.enum(["pending", "active"]).default("pending"),
})

export default Merchant
