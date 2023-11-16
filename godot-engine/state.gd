extends Node

var get_list_prices_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_list_prices_callback")))
var get_signer_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_signer_callback")))
var get_address_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_address_callback")))
var get_allowance_wavax_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_allowance_wavax_callback")))
var get_allowance_game_token_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_allowance_game_token_callback")))
var get_wait_wavax_token_tx_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_wait_wavax_token_tx_callback")))
var get_wait_game_token_tx_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_wait_game_token_tx_callback")))
var get_wait_send_token_tx_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_wait_send_token_tx_callback")))
var get_approve_game_token_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_approve_game_token_callback")))
var get_send_token_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_send_token_callback")))
var get_call_fees_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_call_fees_callback")))
var get_tx_id_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_tx_id_callback")))
var console = JavaScriptBridge.get_interface("console")
var window = JavaScriptBridge.get_interface("window")
var ethers = JavaScriptBridge.get_interface("ethers")
var fees
var fees_wei

var address_input: String = ""
var is_address = false
var is_valid_amount = false
var amount_input: String = ""
var polygon_id = "12532609583862916517"
var wavax_token = "0xd00ae08403B9bbb9124bB305C09058E32C39A48c"
var game_token = "0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4"
var send_token_address: String = "0x94409A2D4fdc713daC8fc911B89a9Fe0A6a7eC80"
var send_tokens_contract
var amount_parsed
var signer
var wallet_address
var hash

var prices = {
  "link": "",
  "aave": "",
  "btc": "",
  "eth": "",
  "matic": "",
  "ape": "",
}

func ask_for_price_list():
  var price_list_contract = window.price_list_contract

  price_list_contract.getPriceList().then(get_list_prices_callback_ref)

func get_list_prices_callback(args):
  prices.link = window.Number(ethers.formatUnits(args[0][0], 8))
  prices.aave = window.Number(ethers.formatUnits(args[0][1], 8))
  prices.btc = window.Number(ethers.formatUnits(args[0][2], 8))
  prices.eth = window.Number(ethers.formatUnits(args[0][3], 8))
  prices.matic = window.Number(ethers.formatUnits(args[0][4], 8))
  prices.ape = window.Number(ethers.formatUnits(args[0][5], 8))


func ask_for_address():
  var edit_text = load("res://edit_text.tscn").instantiate()
  edit_text.title = "Wallet address"
  edit_text.ok_button_text = "Submit address"
  get_tree().root.add_child(edit_text)
  edit_text.popup_centered()
  await edit_text.confirmed
  if(ethers.isAddress(edit_text.input_text.text)):
    address_input = edit_text.input_text.text
    is_address = true
  else:
    is_address = false
  edit_text.queue_free()

func ask_for_amount():
  var edit_text = load("res://edit_text.tscn").instantiate()
  edit_text.title = "Token amount"
  edit_text.ok_button_text = "Submit amount"
  get_tree().root.add_child(edit_text)
  edit_text.popup_centered()
  await edit_text.confirmed
  if edit_text.input_text.text.is_valid_float() or edit_text.input_text.text.is_valid_int():
    amount_input = edit_text.input_text.text
    is_valid_amount = true
  else:
    is_valid_amount = false
  edit_text.queue_free()

func calc_fees():
  send_tokens_contract = window.send_tokens_contract
  amount_parsed = ethers.parseUnits(amount_input, 18).toString()
  send_tokens_contract.getFeePrediction(
    polygon_id,
    address_input,
    "Send {amount} tokens".format({ "amount": amount_input}),
    wavax_token,
    game_token,
    amount_parsed
  ).then(get_call_fees_callback_ref)

func get_call_fees_callback(args):
  fees_wei = args[0]
  fees = window.Number(ethers.formatUnits(fees_wei, 18))

func send_tokens():
  window.provider.getSigner().then(get_signer_callback_ref)
  
func get_signer_callback(args):
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
    window.wavax_token_contract.connect(signer).approve(send_token_address, fees_wei).then(get_wait_wavax_token_tx_callback_ref)

func get_wait_wavax_token_tx_callback(args):
  args[0].wait().then(get_approve_game_token_callback_ref)

func get_approve_game_token_callback(_args):
  window.game_token_contract.allowance(wallet_address, send_token_address).then(get_allowance_game_token_callback_ref)

func get_allowance_game_token_callback(args):
  if(args[0].toString().to_int() > amount_parsed.to_int()):
    get_send_token_callback(null)
  else:
    window.game_token_contract.connect(signer).approve(send_token_address, amount_parsed).then(get_wait_game_token_tx_callback_ref)

func get_wait_game_token_tx_callback(args):
  args[0].wait().then(get_send_token_callback_ref)

func get_send_token_callback(_args):
  send_tokens_contract.connect(signer).sendTokenPayNative(
    polygon_id,
    address_input,
    "Send {amount} tokens".format({ "amount": amount_input}),
    game_token,
    amount_parsed
  ).then(get_wait_send_token_tx_callback_ref)

func get_wait_send_token_tx_callback(args):
  args[0].wait().then(get_tx_id_callback_ref)

func get_tx_id_callback(args):
  hash = args[0]
  var transaction_sent_dialogue = load("res://dialogue/transaction_sent.dialogue") as DialogueResource
  DialogueManager.show_example_dialogue_balloon(transaction_sent_dialogue, "transaction_sent")