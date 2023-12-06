export interface JWTPayload {
  iss: string
  sub: string
  iat: number
  exp: number
}

export interface AuthUser {
  userId: string
  address: string
}

export interface PrizeResult {
  prize_id: string
  score: number
  withdraw_prize: string
  requestId: string
}
