import { Module, MiddlewareConsumer, RequestMethod } from '@nestjs/common'
import { RouterModule } from 'nest-router'
import { routes } from './routes'
import { ConfigModule } from './shared/config/config.module'
import { InfoModule } from './info/info.module'
import { HttpsRedirectMiddleware } from './common/middlewares/https-redirection/https-redirection.middleware'
import { JwtModule } from '@nestjs/jwt'
import { ConfigService } from './shared/config/config.service'
import { JwtStrategy } from './common/strategies/jwt.strategy'
import { JwtAuthGuard } from './common/guards/auth/jwt-auth.guard'
import { APP_GUARD } from '@nestjs/core'

@Module({
  imports: [
    RouterModule.forRoutes(routes),
    ConfigModule,
    InfoModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        return {
          secret: config.get('JWT_SECRET_KEY'),
          signOptions: { expiresIn: config.get('JWT_EXPIRY_KEY') },
        }
      },
    }),
  ],
  providers: [
    JwtStrategy,
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
  ],
})
export class ApplicationModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(HttpsRedirectMiddleware).forRoutes({ path: '*', method: RequestMethod.ALL })
  }
}
