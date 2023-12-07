import { ApiProperty } from '@nestjs/swagger'
import { IsString } from 'class-validator'

export class CreateScoreDto {
  @ApiProperty({
    example: 'sc-1234',
    description: 'Score id',
  })
  @IsString()
  scoreId: string

  @ApiProperty({
    example: '0x394429939392929293ffe3',
    description: 'account address',
  })
  @IsString()
  account: string
}
