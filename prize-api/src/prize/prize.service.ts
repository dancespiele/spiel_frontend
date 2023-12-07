import { ConfigService } from '../shared/config/config.service'
import { ethers } from 'ethers'
import RequestPrizeContract from '../shared/contracts/RequestPrize.json'
import {
  SubscriptionManager,
  SecretsManager,
  ResponseListener,
  ReturnType,
  decodeResult,
  FulfillmentCode,
  FunctionsResponse,
} from '@chainlink/functions-toolkit'
import { PrizeResult } from 'src/common/type'
import { Logger, Injectable } from '@nestjs/common'
import { HttpService } from '@nestjs/axios'
import { firstValueFrom } from 'rxjs'

@Injectable()
export class PrizeService {
  constructor(
    private readonly configService: ConfigService,
    private readonly httpServer: HttpService,
  ) {}

  getOwner() {
    return this.configService.get<string>('OWNER')
  }

  getProvider() {
    const provider = new ethers.providers.JsonRpcProvider(this.configService.get('RPC_URL'))

    return provider
  }

  getWallet() {
    const provider = this.getProvider()
    const mnemonic = ethers.Wallet.fromMnemonic(this.configService.get('SEED_WORDS'))

    const wallet = new ethers.Wallet(mnemonic.privateKey, provider)

    return wallet
  }

  getContract() {
    const wallet = this.getWallet()

    const contract = new ethers.Contract(
      this.configService.get('CONSUMER_ADDRESS'),
      RequestPrizeContract.abi,
      wallet,
    )

    return contract
  }

  getFunction(): string {
    return `
      const scoreId = args[0];

      const urlScore = args[1];
      
      const scoreRequest = Functions.makeHttpRequest({
          url: urlScore,
          headers: {
              "Content-Type": "application/json",
          }
      })
    
      const response = await scoreRequest;
      
      if (response.error) {
          throw new Error("Error getting score")
      }

      return Functions.encodeString(response.data);
    `
  }

  async checkElegibleAccount(
    address: string,
    scoreId: string,
    token: string,
  ): Promise<PrizeResult> {
    const routerAddress = this.configService.get<string>('ROUTER_ADDRESS')
    const linkTokenAddress = this.configService.get<string>('LINK_ADDRESS')
    const gatewayUrls = this.configService.get<string[]>('GATEWAY_URLS')
    const donId = this.configService.get<string>('DON_ID')
    const subscriptionId = this.configService.get<string>('SUBSCRIPTION_ID')
    const source = this.getFunction()
    const args = [scoreId, this.configService.get('BACKEND_URL')]
    const contract = this.getContract()

    const expirationTimeMinutes = 1440
    const gasLimit = 300000

    const wallet = this.getWallet()

    const subscriptionManager = new SubscriptionManager({
      signer: wallet,
      linkTokenAddress,
      functionsRouterAddress: routerAddress,
    })

    await subscriptionManager.initialize()

    const gasPriceWei = await wallet.getGasPrice()

    const estimatedCostInJuels = await subscriptionManager.estimateFunctionsRequestCost({
      donId: donId, // ID of the DON to which the Functions request will be sent
      subscriptionId: subscriptionId, // Subscription ID
      callbackGasLimit: gasLimit, // Total gas used by the consumer contract's callback
      gasPriceWei: gasPriceWei.toBigInt(), // Gas price in gWei
    })

    Logger.log(
      `Fulfillment cost estimated to ${ethers.utils.formatEther(estimatedCostInJuels)} LINK`,
    )

    const secretsManager = new SecretsManager({
      signer: wallet,
      functionsRouterAddress: routerAddress,
      donId: donId,
    })

    await secretsManager.initialize()

    const encryptedSecretsObj = await secretsManager.encryptSecrets({ Authoriazation: token })

    const uploadResult = await secretsManager.uploadEncryptedSecretsToDON({
      encryptedSecretsHexstring: encryptedSecretsObj.encryptedSecrets,
      gatewayUrls: gatewayUrls,
      slotId: 0,
      minutesUntilExpiration: expirationTimeMinutes,
    })

    const donHostedSecretsVersion = uploadResult.version

    const transaction = await contract.requestPrize(
      source,
      '0x',
      0,
      donHostedSecretsVersion,
      args,
      [],
      subscriptionId,
      gasLimit,
      ethers.utils.formatBytes32String(donId),
    )

    Logger.log(`Transaction hash: ${transaction.hash}`)

    const responseListener = new ResponseListener({
      provider: this.getProvider(),
      functionsRouterAddress: routerAddress,
    })

    const response: FunctionsResponse = await new Promise((resolve, reject) => {
      responseListener
        .listenForResponseFromTransaction(transaction.hash)
        .then((response) => {
          resolve(response)
        })
        .catch((error) => {
          reject(error)
        })
    })

    if (response.fulfillmentCode !== FulfillmentCode.FULFILLED) {
      throw new Error(`Error getting score: ${response.fulfillmentCode}`)
    }

    const decodedResult = decodeResult(response.responseBytesHexstring, ReturnType.string)
    const decodeResultString = decodedResult.toString()

    const result = JSON.parse(decodeResultString)

    return { requestId: response.requestId, ...result }
  }

  async setElegibleAccount(account: string, requestId) {
    const contract = this.getContract()

    const transaction = await contract.setElegibleAccountPrize(account, requestId)

    Logger.log(`Transaction hash: ${transaction.hash}`)

    await transaction.wait()
  }

  async updateRequestIdPrize(prizeId: string, requestId: string) {
    await firstValueFrom(
      this.httpServer.put(`${this.configService.get('BACKEND_URL')}/prize_requested`, {
        prize_id: prizeId,
        request_id: requestId,
      }),
    )
  }
}
