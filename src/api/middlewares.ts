// src/api/middlewares.ts
import {
  defineMiddlewares,
  authenticate,
} from "@medusajs/framework/http"
import type { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import multer from "multer"

const upload = multer({
  storage: multer.memoryStorage(),
})

function cors(req: MedusaRequest, res: MedusaResponse, next) {
  res.header("Access-Control-Allow-Origin", "http://localhost:3000")
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept, Authorization"
  )
  res.header(
    "Access-Control-Allow-Methods",
    "GET, POST, PUT, PATCH, DELETE, OPTIONS"
  )

  // IMPORTANT: short-circuit preflight
  if (req.method === "OPTIONS") {
    res.status(200).send()
    return
  }

  next()
}

export default defineMiddlewares({
  routes: [
    // 🔹 CORS must run FIRST for all merchant routes
    {
      matcher: "/merchant*",
      middlewares: [cors],
    },

    {
      method: ["POST", "OPTIONS"],
      matcher: "/merchant/uploads",
      //   bodyParser: false,
      middlewares: [
        // Multer injects req.files
        authenticate("merchant", ["session", "bearer"]),
        // @ts-ignore – Medusa request typing does not include Multer
        upload.array("files"),
      ],
    },

    // 🔹 Merchant registration
    {
      matcher: "/merchant",
      method: "POST",
      middlewares: [
        authenticate("merchant", ["session", "bearer"], {
          allowUnregistered: true,
        }),
      ],
    },

    {
      matcher: "/merchant/regions*",
      middlewares: [
        authenticate("merchant", ["session", "bearer"]),
      ],
    },


    // 🔹 Authenticated merchant routes
    {
      matcher: "/merchant/me*",
      middlewares: [
        authenticate("merchant", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/merchant/store*",
      middlewares: [
        authenticate("merchant", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/merchant/products*",
      middlewares: [
        authenticate("merchant", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/merchant/promotions*",
      middlewares: [authenticate("merchant", ["session", "bearer"])],
    },
    {
      matcher: "/merchant/variants*",
      middlewares: [authenticate("merchant", ["session", "bearer"])],
    },
    {
      matcher: "/merchant/collections*",
      middlewares: [
        authenticate("merchant", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/merchant/categories*",
      middlewares: [
        authenticate("merchant", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/merchant/stock-locations*",
      middlewares: [
        authenticate("merchant", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/merchant/inventory*",
      middlewares: [
        authenticate("merchant", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/merchant/shipping-profiles*",
      middlewares: [
        authenticate("merchant", ["session", "bearer"]),
      ],
    },
  ],
})
