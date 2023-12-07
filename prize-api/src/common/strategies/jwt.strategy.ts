import { Injectable } from '@nestjs/common'
import { PassportStrategy } from '@nestjs/passport'
import { JWTPayload } from '../type'
import { ExtractJwt, Strategy } from 'passport-jwt'
import { ConfigService } from '../../shared/config/config.service'
import { AuthUser } from '../type'

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(configService: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get('JWT_SECRET_KEY'),
    })
  }

  validate(payload: JWTPayload): AuthUser {
    return {
      sessionId: payload.sub,
      address: payload.iss,
    }
  }
}
