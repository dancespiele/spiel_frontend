class_name ConfigEnv

var network := "testnet"
var env_name = "production"

var endpoints = {
  "development": {
    "backend_url": "https://localhost:3100",
    "prize_url": "https://localhost:3200",
  },
  "production": {
    "backend_url": "https://spielcrypto.xyz:3100",
    "prize_url": "https://spielcrypto.xyz:3200",
  }
}

func get_endpoint():
  return endpoints.get(env_name)
