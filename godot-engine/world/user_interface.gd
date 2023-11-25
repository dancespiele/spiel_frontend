extends Control

var provider: JavaScriptObject

var ethers = JavaScriptBridge.get_interface("ethers")
var ethereum = JavaScriptBridge.get_interface("ethereum")
var console = JavaScriptBridge.get_interface("console")
var window = JavaScriptBridge.get_interface("window")

var get_file_feed_price_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_file_feed_price_callback")))
var get_file_send_token_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_file_send_token_callback")))
var get_file_destroy_box_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_file_destroy_box_callback")))
var get_file_feed_price_json_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_file_feed_price_json_callback")))
var get_file_destroy_box_json_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_file_destroy_box_json_callback")))
var get_send_token_json_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_file_send_token_json_callback")))
var get_IERC20_token_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_IERC20_token_callback")))
var get_IERC20_token_json_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_IERC20_token_json_callback")))
var get_wavax_token_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_wavax_token_callback")))
var get_wavax_token_json_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_wavax_token_json_callback")))
var get_link_token_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_link_token_callback")))
var get_link_token_json_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_link_token_json_callback")))
var connect_request_callback_ref = JavaScriptBridge.create_callback(Callable(self, "connect_request_callback"))
var get_signer_callback_ref = JavaScriptBridge.create_callback(Callable(self, "get_signer_callback"))
var get_address_callback_ref = JavaScriptBridge.create_callback(Callable(self, "get_address_callback"))
var disconnect_callback_ref = JavaScriptBridge.create_callback((Callable(self, "disconnect_callback")))

var feed_price_address: String = "0x275d6F77fC33FF5cb40c59e57dAAEB6fCc955082"
var send_token_address: String = "0x7c6DBfBECdc3b54118F9e57F39aE884ef9e4D686"
var wavax_token_address: String = "0xd00ae08403B9bbb9124bB305C09058E32C39A48c"
var game_token_address: String = "0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4"
var link_token_address: String = "0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846"
var destroy_box_address: String = "0xdb7124CA606C8353582448403e1C4B8beb98d17b"

func _init():
	get_file_data()

	if (ethereum):
		window.BrowserProvider = ethers.BrowserProvider
		provider = JavaScriptBridge.create_object("BrowserProvider", ethereum)
		window.provider = provider


func get_file_data():
	window.Contract = ethers.Contract
	window.fetch("/public/contracts/FeedTokensPrice.json").then(get_file_feed_price_callback_ref)
	window.fetch("/public/contracts/CCIPSendTokens.json").then(get_file_send_token_callback_ref)
	window.fetch("/public/contracts/IERC20.json").then(get_IERC20_token_callback_ref)
	window.fetch("/public/contracts/WAVAX.json").then(get_wavax_token_callback_ref)
	window.fetch("/public/contracts/LinkTokenInterface.json").then(get_link_token_callback_ref)
	window.fetch("/public/contracts/DestroyBox.json").then(get_file_destroy_box_callback_ref)

func get_file_feed_price_callback(args):
	args[0].json().then(get_file_feed_price_json_callback_ref)

func get_file_send_token_callback(args):
	args[0].json().then(get_send_token_json_callback_ref)

func get_IERC20_token_callback(args):
	args[0].json().then(get_IERC20_token_json_callback_ref)

func get_wavax_token_callback(args):
	args[0].json().then(get_wavax_token_json_callback_ref)

func get_link_token_callback(args):
	args[0].json().then(get_link_token_json_callback_ref)

func get_file_destroy_box_callback(args):
	args[0].json().then(get_file_destroy_box_json_callback_ref)

func get_file_feed_price_json_callback(args):
	var price_list_contract = JavaScriptBridge.create_object("Contract", feed_price_address, args[0].abi, provider)
	window.price_list_contract = price_list_contract

func get_file_send_token_json_callback(args):
	var send_tokens_contract = JavaScriptBridge.create_object("Contract", send_token_address, args[0].abi, provider)
	window.send_tokens_contract = send_tokens_contract

func get_IERC20_token_json_callback(args):
	var game_token_contract = JavaScriptBridge.create_object("Contract", game_token_address, args[0].abi, provider)
	window.game_token_contract = game_token_contract

func get_wavax_token_json_callback(args):  
	var wavax_token_contract = JavaScriptBridge.create_object("Contract", wavax_token_address, args[0].abi, provider)
	window.wavax_token_contract = wavax_token_contract

func get_link_token_json_callback(args):
	var link_token_contract = JavaScriptBridge.create_object("Contract", link_token_address, args[0].abi, provider)
	window.link_token_contract = link_token_contract

func get_file_destroy_box_json_callback(args):
	var destroy_box_contract = JavaScriptBridge.create_object("Contract", destroy_box_address, args[0].abi, provider)
	window.destroy_box_contract = destroy_box_contract

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
	if args:
		window.Signer = args[0]
		args[0].getAddress().then(get_address_callback_ref)

func get_address_callback(args):
	$WalletConnect.set_text(Utils.shortWalletAddress(args[0].address))
	
func _on_wallet_connect_pressed():
	connect_handled()
