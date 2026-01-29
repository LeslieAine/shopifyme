import { model } from "@medusajs/framework/utils"

const Merchant = model.define("merchant", {
  id: model.id().primaryKey(),

  name: model.text(),
  email: model.text(),

  // ownership link
  store_id: model.text().nullable(),

  status: model.enum(["pending", "active"]).default("pending"),
})

export default Merchant





// import { model } from "@medusajs/framework/utils"

// const Merchant = model.define("merchant", {
//   id: model.id().primaryKey(),

//   name: model.text(),

//   email: model.text().unique(),

//   status: model.enum(["pending", "active"]).default("pending"),
// })

// export default Merchant
