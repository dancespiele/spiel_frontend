extends Node 

signal started_packtingo

var window := JavaScriptBridge.get_interface("window")
var console := JavaScriptBridge.get_interface("console")
var ethereum := JavaScriptBridge.get_interface("ethereum")
var add_network_callback_ref = JavaScriptBridge.create_callback((Callable(self, "add_network_callback")))

var list_price = ListPrice.new()
var send_tokens = SendTokens.new()
var destroy_box = DestroyBox.new()
var avax_tokens = AvaxTokens.new()
var utils = Utils.new()
var chainId: String

var is_account_connected := false
var operation: String

func ask_for_price_list():
	list_price.get_price_list()

func ask_for_address():
	await utils.set_address()

func ask_for_amount():
	await utils.set_amount()

func ask_wrap_token():
	operation = "avax_tokens"
	avax_tokens.wrap_token(utils.amount_input)

func ask_unwrap_token():
	operation = "avax_tokens"
	avax_tokens.unwrap_token(utils.amount_input)

func calc_fees():
	send_tokens.get_calc_fees(utils.address_input, utils.amount_input)

func ask_send_tokens():
	operation = "send_tokens"
	send_tokens.start_transaction()

func play_destroy_the_box():
	operation = "destroy_box"
	destroy_box.get_random_box()

func ask_change_network():
	Utils.checkOrswitchNetwork().catch(add_network_callback_ref)

func add_network_callback(_args):
	JavaScriptBridge.eval("window.addChainNetwork = {
		method: 'wallet_addEthereumChain', params: [{
			chainId: '0xa869',
			chainName: 'Avalanche Fuji Testnet',
			rpcUrls:['https://api.avax-test.network/ext/bc/C/rpc'],
			blockExplorerUrls: ['https://testnet.snowtrace.io'],
			nativeCurrency: { name: 'Avalanche', symbol: 'AVAX', decimals: '18'}}]}")

	ethereum.request(window.addChainNetwork)