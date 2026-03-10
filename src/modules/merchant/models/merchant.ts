// src/modules/merchant/models/merchant.ts
import { model } from "@medusajs/framework/utils"

const Merchant = model.define("merchant", {
  id: model.id().primaryKey(),

  name: model.text(),
  email: model.text(),

  // ownership link
  store_id: model.text().nullable(),
  sales_channel_id: model.text().nullable(),
  stock_location_id: model.text().nullable(),
  default_shipping_profile_id: model.text().nullable(),
  region_ids: model.json().nullable(),
  warehouse_address_line_1: model.text().nullable(),
  warehouse_city: model.text().nullable(),
  warehouse_postal_code: model.text().nullable(),
  warehouse_country_code: model.text().nullable(),
  warehouse_phone: model.text().nullable(),

  status: model.enum(["pending", "active"]).default("pending"),
})

export default Merchant


