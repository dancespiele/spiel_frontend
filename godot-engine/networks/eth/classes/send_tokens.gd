class_name SendTokens extends EthConfig

var get_signer_send_tokens_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_signer_send_tokens_callback")))
var get_address_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_address_callback")))
var get_allowance_wavax_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_allowance_wavax_callback")))
var get_allowance_game_token_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_allowance_game_token_callback")))
var get_wait_wavax_token_tx_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_wait_wavax_token_tx_callback")))
var get_error_wait_token_tx_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_error_wait_token_tx_callback")))
var get_approve_game_token_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_approve_game_token_callback")))
var get_wait_game_token_tx_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_wait_game_token_tx_callback")))
var get_wait_send_token_tx_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_wait_send_token_tx_callback")))
var get_error_wait_send_token_tx_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_error_wait_send_token_tx_callback")))
var get_call_fees_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_call_fees_callback")))
var get_tx_id_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_tx_id_callback")))
var get_send_token_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_send_token_callback")))

var network_id: String
var wavax_token: String = get_address().wavax_token_address
var game_token: String = get_address().game_token_address
var send_token_address: String = get_address().send_token_address
var wallet_address: String
var is_address := false
var is_valid_amount := false
var amount_parsed: String
var fees: float
var address_input: String
var amount_input: String
var fees_wei
var signer: JavaScriptObject
var tx_hash: String
var token: String
var error_message: String

func get_calc_fees(address_input_arg: String, amount_input_arg: String):
	address_input = address_input_arg
	amount_input = amount_input_arg
	amount_parsed = ethers.parseUnits(amount_input, 18).toString()
	window.send_tokens_contract.getFeePrediction(
		network_id,
		address_input,
		"Send {amount} tokens".format({ "amount": amount_input}),
		wavax_token,
		game_token,
		amount_parsed
	).then(get_call_fees_callback_ref)

func get_call_fees_callback(args):
	fees_wei = args[0]
	fees = window.Number(ethers.formatUnits(fees_wei, 18))

func start_transaction():
	window.provider.getSigner().then(get_signer_send_tokens_callback_ref)
	
func get_signer_send_tokens_callback(args):
	if args[0]:
		signer = args[0]
		signer.getAddress().then(get_address_callback_ref)

func get_address_callback(args):
	wallet_address = args[0]
	window.wavax_token_contract.allowance(wallet_address, send_token_address).then(get_allowance_wavax_callback_ref)

func get_allowance_wavax_callback(args):
	if(args[0].toString().to_int() > fees_wei.toString().to_int()):
		get_approve_game_token_callback(null)
	else:
		token = "WAVAX"
		Utils.add_dialogue("approve_token", Utils.dialogueUrl.feedback)
		window.wavax_token_contract.connect(signer).approve(
			send_token_address, fees_wei
		).then(
			get_wait_wavax_token_tx_callback_ref
		).catch(get_error_wait_token_tx_callback_ref)

func get_wait_wavax_token_tx_callback(args):
	args[0].wait().then(get_approve_game_token_callback_ref)

func get_approve_game_token_callback(_args):
	window.game_token_contract.allowance(wallet_address, send_token_address).then(get_allowance_game_token_callback_ref)

func get_allowance_game_token_callback(args):
	if(args[0].toString().to_int() > amount_parsed.to_int()):
		get_send_token_callback(null)
	else:
		token = "GAME"
		Utils.add_dialogue("approve_token", Utils.dialogueUrl.feedback)
		window.game_token_contract.connect(signer).approve(
			send_token_address, amount_parsed
		).then(
			get_wait_game_token_tx_callback_ref
		).catch(get_error_wait_token_tx_callback_ref)

func get_error_wait_token_tx_callback(args):
	error_message = args[0].message
	Utils.add_dialogue("send_tokens_approve_error", Utils.dialogueUrl.error_handle)

func get_wait_game_token_tx_callback(args):
	args[0].wait().then(get_send_token_callback_ref)


func get_send_token_callback(_args):
	Utils.add_dialogue("sign_contract", Utils.dialogueUrl.feedback)
	window.send_tokens_contract.connect(signer).sendTokenPayNative(
		network_id,
		address_input,
		"Send {amount} tokens".format({ "amount": amount_input}),
		game_token,
		amount_parsed
	).then(
		get_wait_send_token_tx_callback_ref
	).catch(get_error_wait_send_token_tx_callback_ref)

func get_wait_send_token_tx_callback(args):
	args[0].wait().then(get_tx_id_callback_ref)

func get_error_wait_send_token_tx_callback(args):
	error_message = args[0].message
	Utils.add_dialogue("send_tokens_sign_error", Utils.dialogueUrl.error_handle)	

func get_tx_id_callback(args):
	console.log(args[0])
	tx_hash = args[0].hash
	Utils.add_dialogue("transaction_sent", Utils.dialogueUrl.feedback)