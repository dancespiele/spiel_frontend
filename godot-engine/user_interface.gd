extends Control

var provider: JavaScriptObject

var ethers = JavaScriptBridge.get_interface("ethers")
var ethereum = JavaScriptBridge.get_interface("ethereum")
var console = JavaScriptBridge.get_interface("console")
var window = JavaScriptBridge.get_interface("window")

var get_file_data_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_file_data_callback")))
var get_file_json_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_file_json_callback")))
var connect_request_callback_ref = JavaScriptBridge.create_callback(Callable(self, "connect_request_callback"))
var get_signer_callback_ref = JavaScriptBridge.create_callback(Callable(self, "get_signer_callback"))
var get_address_callback_ref = JavaScriptBridge.create_callback(Callable(self, "get_address_callback"))
var disconnect_callback_ref = JavaScriptBridge.create_callback((Callable(self, "disconnect_callback")))

var address_contract: String = "0x801df6B4f18Ae08Ed756D01a56220B9c4585F1b4"
var price_list

func _init():
  get_file_data()

  if (ethereum):
    window.BrowserProvider = ethers.BrowserProvider
    provider = JavaScriptBridge.create_object("BrowserProvider", ethereum)


func get_file_data():
  window.fetch("/public/contracts/FeedTokensPrice.json").then(get_file_data_callback_ref)

func get_file_data_callback(args):
  window.Contract = ethers.Contract
  args[0].json().then(get_file_json_callback_ref)

func get_file_json_callback(args):
  price_list = JavaScriptBridge.create_object("Contract", address_contract, args[0].abi, provider)
  window.price_list = price_list

func connect_handled():

  if provider and $WalletConnect.get_text() == "Connect Wallet": 
    provider.send("eth_requestAccounts", []).then(connect_request_callback_ref)
  else:
    $WalletConnect.set_text("Connect Wallet")
    ethereum.on('disconnect', disconnect_callback_ref)

func connect_request_callback(_args):
  provider.getSigner().then(get_address_callback_ref)

func disconnect_callback(args):
  console.log(args[0])

func get_signer_callback(args):
  args[0].getAddress().then(get_address_callback_ref)

func get_address_callback(args):
  $WalletConnect.set_text(args[0].address)
  
func _on_wallet_connect_pressed():
  connect_handled()
