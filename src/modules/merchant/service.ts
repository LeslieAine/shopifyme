import { MedusaService } from "@medusajs/framework/utils"
import Merchant from "./models/merchant"

export default class MerchantService extends MedusaService({
  Merchant,
}) {}
