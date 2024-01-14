extends Control

var provider: JavaScriptObject

var ethers = JavaScriptBridge.get_interface("ethers")
var ethereum = JavaScriptBridge.get_interface("ethereum")
var console = JavaScriptBridge.get_interface("console")
var window = JavaScriptBridge.get_interface("window")
var process = JavaScriptBridge.get_interface("process")

var add_network_callback_ref = JavaScriptBridge.create_callback((Callable(self, "add_network_callback")))
var get_file_feed_price_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_file_feed_price_callback")))
var get_file_send_token_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_file_send_token_callback")))
var get_request_prize_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_request_prize_callback")));
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
var get_request_prize_json_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_request_prize_json_callback")))
var connect_request_callback_ref = JavaScriptBridge.create_callback(Callable(self, "connect_request_callback"))
var get_signer_callback_ref = JavaScriptBridge.create_callback(Callable(self, "get_signer_callback"))
var get_signature_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_signature_callback")))

var feed_price_address: String = "0x275d6F77fC33FF5cb40c59e57dAAEB6fCc955082"
var send_token_address: String = "0x7FB00d4D6A29744812b198802c6466cD9D2b9EfD"
var wavax_token_address: String = "0xd00ae08403B9bbb9124bB305C09058E32C39A48c"
var game_token_address: String = "0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4"
var request_prize_address: String = "0x6f3b2f5FA9cccA99fe922975E96F509eB5cF3345"
var link_token_address: String = "0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846"
var destroy_box_address: String = "0xdb7124CA606C8353582448403e1C4B8beb98d17b"

var message: String
var signature: String
var auth: Auth

func _init():
	auth = Auth.new()

	get_file_data()

	if (ethereum):
		window.BrowserProvider = ethers.BrowserProvider
		provider = JavaScriptBridge.create_object("BrowserProvider", ethereum)
		window.provider = provider
		Utils.checkOrswitchNetwork().catch(add_network_callback_ref)

func _ready():
	var is_account_connected = check_account_connected()

	if is_account_connected:
		connect_request_callback(null)

func add_network_callback(_args):
	JavaScriptBridge.eval("window.addChainNetwork = {
		method: 'wallet_addEthereumChain', params: [{
			chainId: '0xa869',
			chainName: 'Avalanche Fuji Testnet',
			rpcUrls:['https://api.avax-test.network/ext/bc/C/rpc'],
			blockExplorerUrls: ['https://testnet.snowtrace.io'],
			nativeCurrency: { name: 'Avalanche', symbol: 'AVAX', decimals: '18'}}]}")

	ethereum.request(window.addChainNetwork)

func check_account_connected():
	var claims = auth.get_claims()
	if claims and claims.iss:
		State.is_account_connected = true
	
	return State.is_account_connected

func get_file_data():
	window.Contract = ethers.Contract
	window.fetch("/public/contracts/FeedTokensPrice.json").then(get_file_feed_price_callback_ref)
	window.fetch("/public/contracts/CCIPSendTokens.json").then(get_file_send_token_callback_ref)
	window.fetch("/public/contracts/IERC20.json").then(get_IERC20_token_callback_ref)
	window.fetch("/public/contracts/WAVAX.json").then(get_wavax_token_callback_ref)
	window.fetch("/public/contracts/LinkTokenInterface.json").then(get_link_token_callback_ref)
	window.fetch("/public/contracts/DestroyBox.json").then(get_file_destroy_box_callback_ref)
	window.fetch("/public/contracts/RequestPrize.json").then(get_request_prize_callback_ref)

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

func get_request_prize_callback(args):
	args[0].json().then(get_request_prize_json_callback_ref)

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

func get_request_prize_json_callback(args):
	var request_prize_contract = JavaScriptBridge.create_object("Contract", request_prize_address, args[0].abi, provider)
	window.request_prize_contract = request_prize_contract

func get_file_destroy_box_json_callback(args):
	var destroy_box_contract = JavaScriptBridge.create_object("Contract", destroy_box_address, args[0].abi, provider)
	window.destroy_box_contract = destroy_box_contract

func connect_handled():
	if provider and $WalletConnect.get_text() == "Connect Wallet":
		provider.send("eth_requestAccounts", []).then(connect_request_callback_ref)
	else:
		$WalletConnect.set_text("Connect Wallet")
		disconnect_account()

func connect_request_callback(_args):
	provider.getSigner().then(get_signer_callback_ref)

func disconnect_account():
	auth.delete_token()
	State.is_account_connected = false


func get_signer_callback(args):
	var signer = args[0]
	window.signer = signer

	var is_account_connected = check_account_connected()

	var endpoint = "{backend_url}/nonce/{address}".format({
		"backend_url": OS.get_environment("BACKEND_URL"),
		"address": window.signer.address
	})

	if !is_account_connected:
		Utils.request(
			self,
			self._request_nonce_completed,
			["Content-Type: application/json"],
			endpoint,
			HTTPClient.METHOD_GET,
		)
	else:
		$WalletConnect.set_text(Utils.shortWalletAddress(window.signer.address))
		var token = auth.get_token()
		check_prizes(token)

func _request_nonce_completed(_result, _response_code, _headers, body):
	var response = JSON.parse_string(body.get_string_from_utf8())
	message = auth.create_siwe_message(window.signer.address, 'Sign in with Ethereum to the Web4dlife metaverso.', response)
	window.signer.signMessage(message).then(get_signature_callback_ref)

func get_signature_callback(args):
	signature = args[0]
	
	var client_assertion = JSON.stringify({"signature": signature, "message": message})

	var endpoint = "{endpoint}/login".format({"endpoint": OS.get_environment("BACKEND_URL")})

	Utils.request(
		self,
		self._request_login_completed,
		["Content-Type: application/json"],
		endpoint,
		HTTPClient.METHOD_POST,
		client_assertion
	)

func _request_login_completed(_result, _response_code, _headers, body):
	var response = JSON.parse_string(body.get_string_from_utf8())

	auth.store_token(response)
	State.is_account_connected = true

	$WalletConnect.set_text(Utils.shortWalletAddress(window.signer.address))

	check_prizes(response)

func check_prizes(token: String):
	var endpoint = "{endpoint}/prize".format({"endpoint": OS.get_environment("BACKEND_URL")});

	Utils.request(
		self,
		self._request_prize_completed,
		["Content-Type: application/json", "Authorization: {auth}".format({"auth": token})],
		endpoint,
		HTTPClient.METHOD_GET,
	)

func _request_prize_completed(_result, response_code, _headers, body):
	if response_code == 500:
		console.error("Error to get prizes or not prizes yet")
		return

	var response = JSON.parse_string(body.get_string_from_utf8())

	if response.size() > 0:
		State.prizes = response

		var prize_box = preload("res://world/prize_box.tscn").instantiate()
		var parent = get_parent()
		parent.add_child(prize_box)
		prize_box.position = Vector3(-71.501, 5.55966, -8.50782)
		console.log("Created")

func setAddress(addr: String):
	$WalletConnect.set_text(Utils.shortWalletAddress(addr))

func _on_wallet_connect_pressed():
	connect_handled()