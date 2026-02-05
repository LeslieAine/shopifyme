// import {
//   AuthenticatedMedusaRequest,
//   MedusaResponse,
// } from "@medusajs/framework/http"
// import { MedusaError } from "@medusajs/framework/utils"
// import { uploadFilesWorkflow } from "@medusajs/medusa/core-flows"

// // ✅ IMPORT Multer types DIRECTLY
// // import type { File as MulterFile } from "multer"

// export async function POST(
//   req: AuthenticatedMedusaRequest,
//   res: MedusaResponse
// ) {
//   // ✅ Explicit cast — required
// //   const files = (req as any).files as MulterFile[]
// const files = req.files as Express.Multer.File[]

//   if (!files || files.length === 0) {
//     throw new MedusaError(
//       MedusaError.Types.INVALID_DATA,
//       "No files uploaded"
//     )
//   }

//   const { result } = await uploadFilesWorkflow(req.scope).run({
//     input: {
//       files: files.map((file) => ({
//         filename: file.originalname,
//         mimeType: file.mimetype,
//         content: file.buffer.toString("binary"),
//         access: "public",
//       })),
//     },
//   })

//   res.status(200).json({ files: result })
// }

import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { uploadFilesWorkflow } from "@medusajs/medusa/core-flows"

export async function POST(
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) {
  const files = req.files as Express.Multer.File[]

  if (!files || files.length === 0) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "No files uploaded"
    )
  }

  const { result } = await uploadFilesWorkflow(req.scope).run({
    input: {
      files: files.map((file) => ({
        filename: file.originalname,
        mimeType: file.mimetype,
        content: file.buffer.toString("base64"), //REQUIRED
        access: "public",
      })),
    },
  })

  res.status(200).json({ files: result })
}
