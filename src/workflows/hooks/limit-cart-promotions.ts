// src/workflows/hooks/limit-cart-promotions.ts

import { updateCartPromotionsWorkflow } from "@medusajs/medusa/core-flows"
import { MedusaError, PromotionActions } from "@medusajs/framework/utils"

updateCartPromotionsWorkflow.hooks.validate(
  async ({ input, cart }) => {

    // Only care about ADD
    if (input.action !== PromotionActions.ADD) {
      return
    }

    if (!input.promo_codes || input.promo_codes.length === 0) {
      return
    }

    const existingPromotions = cart.promotions || []

    if (existingPromotions.length > 0) {
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        "Only one promotion can be applied to a cart."
      )
    }
  }
)
