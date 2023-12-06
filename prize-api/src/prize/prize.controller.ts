import { Controller, Post, Body, InternalServerErrorException, Req, Logger } from '@nestjs/common'
import {
  ApiTags,
  ApiResponse,
  ApiOperation,
  ApiParam,
  ApiBearerAuth,
  ApiBody,
} from '@nestjs/swagger'
import { CreateScoreDto } from './dtos/create-score.dto'
import { PrizeService } from './prize.service'

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
  @ApiParam({
    description: 'did of the asset',
    name: 'did',
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
  async setElegibleAccount(@Body() scoreData: CreateScoreDto, @Req() req: Request) {
    try {
      const token = req.headers['authorization']
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
