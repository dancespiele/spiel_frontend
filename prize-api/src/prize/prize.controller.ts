import {
  Controller,
  Post,
  Body,
  InternalServerErrorException,
  Req,
  Logger,
  ForbiddenException,
} from '@nestjs/common'
import { ApiTags, ApiResponse, ApiOperation, ApiBearerAuth, ApiBody } from '@nestjs/swagger'
import { CreateScoreDto } from './dtos/create-score.dto'
import { PrizeService } from './prize.service'
import { User } from '../common/decorators/user.decorator'

@ApiTags('Widget')
@Controller()
export class PrizeController {
  constructor(private readonly prizeService: PrizeService) {}

  @Post()
  @ApiOperation({
    description: 'Set account elegible for prize',
  })
  @ApiBearerAuth('Authorization')
  @ApiBody({
    type: CreateScoreDto,
  })
  @ApiResponse({
    status: 200,
    description: '',
  })
  @ApiResponse({
    status: 400,
    description: 'Bad Request',
  })
  @ApiResponse({
    status: 404,
    description: 'Not found',
  })
  async setElegibleAccount(@Body() scoreData: CreateScoreDto, @User() user, @Req() req: any) {
    try {
      if (user.address.toLowerCase() !== this.prizeService.getOwner().toLowerCase()) {
        throw new ForbiddenException('Only owner can set account as elegible')
      }
      const token = req.headers['authorization'].replace('Bearer ', '')
      const { requestId, score, withdraw_prize, prize_id } =
        await this.prizeService.checkElegibleAccount(scoreData.account, scoreData.scoreId, token)

      if (score <= 0 || score > 4 || withdraw_prize) {
        Logger.warn('Score out of range or prize already withdrawn, nothing to do here')
        return
      }

      await this.prizeService.setElegibleAccount(scoreData.account, requestId)

      Logger.log('Elegible account set')

      await this.prizeService.updateRequestIdPrize(prize_id, requestId)
    } catch (error) {
      throw new InternalServerErrorException(error)
    }
  }
}
