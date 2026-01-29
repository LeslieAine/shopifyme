import {
    defineMiddlewares,
    authenticate,
} from "@medusajs/framework/http"

export default defineMiddlewares({
    routes: [
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
    ],
})
