class_name AvaxTokens

var get_signer_send_tokens_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_signer_send_tokens_callback")))
var get_address_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_address_callback")))
var get_operation_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_operation_callback")))
var get_approve_wavax_token_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_approve_wavax_token_callback")))
var get_wait_operation_token_tx_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_wait_operation_token_tx_callback")))
var get_wait_wavax_token_tx_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_wait_wavax_token_tx_callback")))

var ethers := JavaScriptBridge.get_interface("ethers")
var window := JavaScriptBridge.get_interface("window")
var console := JavaScriptBridge.get_interface("console")

var wavax_token := "0xd00ae08403B9bbb9124bB305C09058E32C39A48c"
var send_token_address := "0x7c6DBfBECdc3b54118F9e57F39aE884ef9e4D686"
var operation_type: String
var signer: JavaScriptObject
var wallet_address: String
var amount_parsed: String

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
    window.send_tokens_contract.connect(signer).wrapAvaxToken(window.data).then(get_operation_callback_ref)
  else:
    window.wavax_token_contract.connect(signer).approve(send_token_address, amount_parsed).then(get_wait_wavax_token_tx_callback_ref)

func get_wait_wavax_token_tx_callback(args):
  args[0].wait().then(get_approve_wavax_token_callback_ref)

func get_approve_wavax_token_callback(args):
  console.log(args[0])
  window.send_tokens_contract.connect(signer).unwrapAvaxToken(amount_parsed).then(get_operation_callback_ref)

func get_operation_callback(args):
  args[0].wait().then(get_wait_operation_token_tx_callback_ref)

func get_wait_operation_token_tx_callback(args):
  console.log(args[0])
  var balloon = preload("res://dialogue/balloon.tscn").instantiate()
  var transaction_sent_dialogue = load("res://dialogue/transaction_sent.dialogue") as DialogueResource
  State.get_tree().current_scene.add_child(balloon)
  balloon.start(transaction_sent_dialogue, "transaction_sent")