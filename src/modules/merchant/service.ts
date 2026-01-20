import { MedusaService } from "@medusajs/framework/utils"
import Merchant from "./models/merchant"

class MerchantModuleService extends MedusaService({
  Merchant,
}) {
  async createMerchant(email: string) {
    return this.createMerchants({ email })
  }

  async getByEmail(email: string) {
    const [merchant] = await this.listMerchants({ email })
    return merchant
  }
}

export default MerchantModuleService
