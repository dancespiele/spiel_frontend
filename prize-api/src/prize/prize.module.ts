import { Module } from '@nestjs/common'
import { ConfigModule } from '../shared/config/config.module'
import { PrizeService } from './prize.service'
import { PrizeController } from './prize.controller'
import { HttpModule } from '@nestjs/axios'

@Module({
  imports: [ConfigModule, HttpModule],
  controllers: [PrizeController],
  providers: [PrizeService],
})
export class PrizeModule {}
