class_name EthConfig extends ConfigEnv

var console := JavaScriptBridge.get_interface("console")
var ethers := JavaScriptBridge.get_interface("ethers")
var window := JavaScriptBridge.get_interface("window")
var siwe := JavaScriptBridge.get_interface("siwe")
var ethereum := JavaScriptBridge.get_interface("ethereum")
var localStorage := JavaScriptBridge.get_interface("localStorage")
var jose := JavaScriptBridge.get_interface("jose")

var addresses = {
  "testnet": {
    "feed_price_address":"0x275d6F77fC33FF5cb40c59e57dAAEB6fCc955082",
    "send_token_address":"0x7FB00d4D6A29744812b198802c6466cD9D2b9EfD",
    "wavax_token_address":"0xd00ae08403B9bbb9124bB305C09058E32C39A48c",
    "game_token_address":"0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4",
    "request_prize_address":"0x6f3b2f5FA9cccA99fe922975E96F509eB5cF3345",
    "link_token_address":"0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846",
    "destroy_box_address":"0xdb7124CA606C8353582448403e1C4B8beb98d17b",
    "wavax_token": "0xd00ae08403B9bbb9124bB305C09058E32C39A48c",
  }
}

var fees_network = {
  "testnet": {
    "fee_destroy_ball": "500000000000000000"
  }
}

func get_address():
  return addresses.get(network)


func get_fees():
  return fees_network.get(network)