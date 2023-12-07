module.exports = {
  NODE_ENV: 'staging',
  JWT_SECRET_KEY: process.env.SECRET,
  JWT_EXPIRY_KEY: process.env.JWT_EXPIRY_KEY,
  SEED_WORDS: process.env.SEED_WORDS?.replace(',', ' '),
  RPC_URL: process.env.RPC_URL,
  LINK_ADDRESS: process.env.LINK_ADDRESS,
  ROUTER_ADDRESS: process.env.ROUTER_ADDRESS,
  DON_ID: process.env.DON_ID,
  GATEWAY_URLS: process.env.GATEWAY_URLS?.split(','),
  BACKEND_URL: process.env.BACKEND_URL,
  SUBSCRIPTION_ID: process.env.SUBSCRIPTION_ID,
  OWNER: process.env.OWNER,
  server: {
    hostname: process.env.HOSTNAME,
    port: process.env.PORT,
  },
  src: {
    root: 'dist',
    fileExtension: 'js',
  },
  CONSUMER_ADDRESS: process.env.CONSUMER_ADDRESS,
  security: {
    enableHttpsRedirect: process.env.ENABLE_HTTPS_REDIRECT,
  },
}
