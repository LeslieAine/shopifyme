import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"

export const config = {
  auth: true,
}

type RegisterMerchantBody = {
  business_name: string
}

export async function POST(
  req: MedusaRequest,
  res: MedusaResponse
) {
  /**
   * ✅ TS-safe + runtime-correct auth access
   */
  const userId = req.context?.auth?.actor_id

  if (!userId) {
    return res.status(401).json({ error: "Unauthenticated" })
  }

  const { business_name } = req.body as RegisterMerchantBody

  if (!business_name) {
    return res.status(400).json({
      error: "business_name required",
    })
  }

  const db = req.scope.resolve("db") as {
    query: (sql: string, params?: any[]) => Promise<{ rows: any[] }>
  }

  /**
   * Prevent duplicate merchant for same user
   */
  const existing = await db.query(
    `
    SELECT id FROM merchant_user
    WHERE user_id = $1
    `,
    [userId]
  )

  if (existing.rows.length > 0) {
    return res.status(409).json({
      error: "Merchant already exists for this user",
    })
  }

  /**
   * Create merchant
   */
  const merchantResult = await db.query(
    `
    INSERT INTO merchant (id, name, status)
    VALUES (gen_random_uuid(), $1, 'pending')
    RETURNING *
    `,
    [business_name]
  )

  const merchant = merchantResult.rows[0]

  /**
   * Link user → merchant
   */
  await db.query(
    `
    INSERT INTO merchant_user (id, merchant_id, user_id, role)
    VALUES (gen_random_uuid(), $1, $2, 'owner')
    `,
    [merchant.id, userId]
  )

  res.json({ merchant })
}
