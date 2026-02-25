// import {
//   createWorkflow,
//   createStep,
//   StepResponse,
//   WorkflowResponse,
// } from "@medusajs/framework/workflows-sdk"
// import { setAuthAppMetadataStep } from "@medusajs/medusa/core-flows"
// import MerchantService from "../modules/merchant/service"

// // type CreateMerchantWorkflowInput = {
// //   merchant: {
// //     name: string
// //     email: string
// //   }
// //   authIdentityId: string
// // }

// type CreateMerchantWorkflowInput = {
//   merchant: {
//     name: string
//     email: string
//   }
//   authIdentityId: string
// }


// const createMerchantStep = createStep(
//   "create-merchant-step",
//   async (
//     { merchant }: Pick<CreateMerchantWorkflowInput, "merchant">,
//     { container }
//   ) => {
//     const merchantService = container.resolve<MerchantService>("merchant")

//     const created = await merchantService.createMerchants(merchant)

//     return new StepResponse(created)
//   }
// )

// const createMerchantWorkflow = createWorkflow(
//   "create-merchant",
//   (input: CreateMerchantWorkflowInput) => {
//     const merchant = createMerchantStep({
//       merchant: input.merchant,
//     })

//     setAuthAppMetadataStep({
//       authIdentityId: input.authIdentityId,
//       actorType: "merchant",
//       value: merchant.id,
//     })

//     return new WorkflowResponse(merchant)
//   }
// )

// export default createMerchantWorkflow


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
  region_ids: string[]
  authIdentityId: string
}

const createMerchantStep = createStep(
  "create-merchant-step",
  async (
    { merchant, region_ids }: CreateMerchantWorkflowInput,
    { container }
  ) => {
    const merchantService = container.resolve<MerchantService>("merchant")

    // const created = await merchantService.createMerchants({
    //   ...merchant,
    //   region_ids,
    // })
    const created = await merchantService.createMerchants({
  ...merchant,
  region_ids: {
    values: region_ids,
  },
})


    return new StepResponse(created)
  }
)

const createMerchantWorkflow = createWorkflow(
  "create-merchant",
  (input: CreateMerchantWorkflowInput) => {
    const merchant = createMerchantStep({
      merchant: input.merchant,
      region_ids: input.region_ids,
      authIdentityId: input.authIdentityId,
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
