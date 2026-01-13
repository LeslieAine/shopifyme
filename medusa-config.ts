import { loadEnv, defineConfig } from "@medusajs/framework/utils"

loadEnv(process.env.NODE_ENV || "development", process.cwd())

module.exports = defineConfig({
  projectConfig: {
    databaseUrl: process.env.DATABASE_URL,
    http: {
      storeCors: "http://localhost:3000",
      adminCors: "http://localhost:7001,http://localhost:3000",
      authCors: process.env.AUTH_CORS!,
      jwtSecret: process.env.JWT_SECRET || "supersecret",
      cookieSecret: process.env.COOKIE_SECRET || "supersecret",
    },
  },

  // ✅ CORE MODULES ONLY
  modules: {
    payment: true,
  },

  // ✅ PAYMENT PROVIDERS LIVE HERE (THIS IS THE KEY)
  plugins: [
    {
      resolve: "@medusajs/payment-stripe",
      options: {
        api_key: process.env.STRIPE_SECRET_KEY,
      },
    },
  ],
})



// import { loadEnv, defineConfig } from '@medusajs/framework/utils'

// loadEnv(process.env.NODE_ENV || 'development', process.cwd())

// module.exports = defineConfig({
//   projectConfig: {
//     databaseUrl: process.env.DATABASE_URL,
//     http: {
//       storeCors: "http://localhost:3000",
//       adminCors: "http://localhost:7001,http://localhost:3000",
//       authCors: process.env.AUTH_CORS!,
//       jwtSecret: process.env.JWT_SECRET || "supersecret",
//       cookieSecret: process.env.COOKIE_SECRET || "supersecret",
//     }
//   },
//   modules: {
//     payment: {
//       resolve: "@medusajs/payment-stripe",
//       options: {
//         apiKey: process.env.STRIPE_SECRET_KEY,
//       },
//     },
//   },
// })
