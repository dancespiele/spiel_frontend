class_name AvaxTokens extends EthConfig

var get_signer_send_tokens_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_signer_send_tokens_callback")))
var get_address_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_address_callback")))
var get_operation_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_operation_callback")))
var get_approve_wavax_token_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_approve_wavax_token_callback")))
var get_error_approve_token_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_error_approve_token_callback")))
var get_wait_operation_token_tx_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_wait_operation_token_tx_callback")))
var get_wait_wavax_token_tx_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_wait_wavax_token_tx_callback")))
var get_error_sign_contract_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_error_sign_contract_callback")))

var wavax_token: String = get_address().wavax_token_address
var send_token_address: String = get_address().send_token_address
var operation_type: String
var signer: JavaScriptObject
var wallet_address: String
var amount_parsed: String
var tx_hash: String
var token: String
var error_message: String

func wrap_token(amount_input):
  amount_parsed = ethers.parseUnits(amount_input, 18).toString()
  window.provider.getSigner().then(get_signer_send_tokens_callback_ref)

func unwrap_token(amount_input):
  amount_parsed = ethers.parseUnits(amount_input, 18).toString()
  window.provider.getSigner().then(get_signer_send_tokens_callback_ref)
  

func get_signer_send_tokens_callback(args):
  if args[0]:
    signer = args[0]
    signer.getAddress().then(get_address_callback_ref)

func get_address_callback(args):
  wallet_address = args[0]

  if operation_type == "wrap":
    var data = "window.data = { value: '{value}' }".format({"value": amount_parsed})
    JavaScriptBridge.eval(data)
    Utils.add_dialogue("sign_contract", Utils.dialogueUrl.feedback)
    window.send_tokens_contract.connect(signer).wrapAvaxToken(window.data).then(
      get_operation_callback_ref
    ).catch(get_error_sign_contract_callback_ref)
  else:
    token = "WAVAX"
    Utils.add_dialogue("approve_token", Utils.dialogueUrl.feedback)
    window.wavax_token_contract.connect(signer).approve(
      send_token_address, amount_parsed
    ).then(
      get_wait_wavax_token_tx_callback_ref
    ).catch(get_error_approve_token_callback_ref)

func get_wait_wavax_token_tx_callback(args):
  args[0].wait().then(get_approve_wavax_token_callback_ref)

func get_error_approve_token_callback(args):
  error_message = args[0].message
  Utils.add_dialogue("avax_tokens_approve_error", Utils.dialogueUrl.error_handle)

func get_error_sign_contract_callback(args):
  error_message = args[0].message
  Utils.add_dialogue("avax_tokens_sign_error", Utils.dialogueUrl.error_handle)


func get_approve_wavax_token_callback(_args):
  Utils.add_dialogue("sign_contract", Utils.dialogueUrl.feedback)
  window.send_tokens_contract.connect(signer).unwrapAvaxToken(amount_parsed).then(
    get_operation_callback_ref
  ).catch(
    get_error_sign_contract_callback_ref
  )

func get_operation_callback(args):
  args[0].wait().then(get_wait_operation_token_tx_callback_ref)

func get_wait_operation_token_tx_callback(args):
  tx_hash = args[0].hash
  Utils.add_dialogue("transaction_sent", Utils.dialogueUrl.feedback)