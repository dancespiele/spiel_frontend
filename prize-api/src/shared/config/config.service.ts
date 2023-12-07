/* eslint @typescript-eslint/no-var-requires: 0 */
/* eslint @typescript-eslint/no-unsafe-assignment: 0 */
/* eslint @typescript-eslint/no-unsafe-argument: 0 */
import { Logger } from '@nestjs/common'
import * as Joi from 'joi'
import { get as loGet } from 'lodash'

export interface EnvConfig {
  [key: string]: string
  nvm: any
}

const configProfile = require('../../../config')

const DOTENV_SCHEMA = Joi.object({
  NODE_ENV: Joi.string()
    .valid('development', 'production', 'test', 'staging')
    .default('development'),
  JWT_SECRET_KEY: Joi.string().required().error(new Error('SECRET is required!')),
  JWT_EXPIRY_KEY: Joi.string().default('24h'),
  server: Joi.object({
    hostname: Joi.string().default('127.0.0.1'),
    port: Joi.number().default(3200),
  }),
  RPC_URL: Joi.string().uri().required().error(new Error('RPC_URL is required!')),
  SEED_WORDS: Joi.string().required().error(new Error('SEED_WORDS are required!')),
  CONSUMER_ADDRESS: Joi.string().required().error(new Error('CONSUMER_ADDRESS is required')),
  LINK_ADDRESS: Joi.string().required().error(new Error('LINK_ADDRESS is required')),
  ROUTER_ADDRESS: Joi.string().required().error(new Error('ROUTER_ADDRESS is required')),
  DON_ID: Joi.string().required().error(new Error('DON_ID is required!')),
  GATEWAY_URLS: Joi.array().required().error(new Error('GATEWAY_URLS are required!')),
  BACKEND_URL: Joi.string().required().error(new Error('BACKEND_URL is required!')),
  OWNER: Joi.string().required().error(new Error('OWNER is required!')),
  SUBSCRIPTION_ID: Joi.string().required().error(new Error('SUBSCRIPTION_ID is required!')),
  security: Joi.object({
    enableHttpsRedirect: Joi.bool().default(false),
  }).default({
    enableHttpsRedirect: false,
  }),
})

type DotenvSchemaKeys =
  | 'NODE_ENV'
  | 'server.hostname'
  | 'server.port'
  | 'JWT_SECRET_KEY'
  | 'JWT_EXPIRY_KEY'
  | 'RPC_URL'
  | 'SEED_WORDS'
  | 'CONSUMER_ADDRESS'
  | 'LINK_ADDRESS'
  | 'ROUTER_ADDRESS'
  | 'GATEWAY_URLS'
  | 'BACKEND_URL'
  | 'OWNER'
  | 'DON_ID'
  | 'SUBSCRIPTION_ID'
  | 'security.enableHttpsRedirect'

export class ConfigService {
  private readonly envConfig: EnvConfig

  constructor() {
    this.envConfig = this.validateInput(configProfile)
  }

  get<T>(path: DotenvSchemaKeys): T | undefined {
    return loGet(this.envConfig, path) as unknown as T | undefined
  }

  private validateInput(envConfig: EnvConfig): EnvConfig {
    const { error, value: validatedEnvConfig } = DOTENV_SCHEMA.validate(envConfig, {
      allowUnknown: true,
      stripUnknown: true,
    })
    if (error) {
      Logger.error('Missing configuration please provide followed variable!\n\n', 'ConfigService')
      Logger.error(error.message, 'ConfigService')
      process.exit(2)
    }
    return validatedEnvConfig as EnvConfig
  }
}
