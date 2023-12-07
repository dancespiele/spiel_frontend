export interface JWTPayload {
  iss: string
  sub: string
  iat: number
  exp: number
}

export interface AuthUser {
  sessionId: string
  address: string
}

export interface PrizeResult {
  prize_id: string
  score: number
  withdraw_prize: string
  requestId: string
}
