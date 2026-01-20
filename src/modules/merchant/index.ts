import MerchantModuleService from "./service"
import { Module } from "@medusajs/framework/utils"

export const MERCHANT_MODULE = "merchant"

export default Module(MERCHANT_MODULE, {
  service: MerchantModuleService,
})
