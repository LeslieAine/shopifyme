import { MedusaRequest, MedusaResponse } from "@medusajs/framework"
import { MERCHANT_MODULE } from "../../../modules/merchant"

export async function POST(
  req: MedusaRequest,
  res: MedusaResponse
) {
  const { email } = req.body as { email: string }

  if (!email) {
    res.status(400).json({ message: "email is required" })
    return
  }

  const merchantService = req.scope.resolve(MERCHANT_MODULE)

  const merchant = await merchantService.createMerchant(email)

  res.json({ merchant })
}
