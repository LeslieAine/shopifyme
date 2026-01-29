import {
  createWorkflow,
  createStep,
  StepResponse,
  WorkflowResponse,
} from "@medusajs/framework/workflows-sdk"
import { setAuthAppMetadataStep } from "@medusajs/medusa/core-flows"
import MerchantService from "../modules/merchant/service"

type CreateMerchantWorkflowInput = {
  merchant: {
    name: string
    email: string
  }
  authIdentityId: string
}

const createMerchantStep = createStep(
  "create-merchant-step",
  async (
    { merchant }: Pick<CreateMerchantWorkflowInput, "merchant">,
    { container }
  ) => {
    const merchantService = container.resolve<MerchantService>("merchant")

    const created = await merchantService.createMerchants(merchant)

    return new StepResponse(created)
  }
)

const createMerchantWorkflow = createWorkflow(
  "create-merchant",
  (input: CreateMerchantWorkflowInput) => {
    const merchant = createMerchantStep({
      merchant: input.merchant,
    })

    setAuthAppMetadataStep({
      authIdentityId: input.authIdentityId,
      actorType: "merchant",
      value: merchant.id,
    })

    return new WorkflowResponse(merchant)
  }
)

export default createMerchantWorkflow
