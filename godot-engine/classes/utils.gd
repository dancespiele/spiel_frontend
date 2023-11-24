class_name Utils

var amount_input: String
var address_input: String
var is_valid_address: bool
var is_valid_amount: bool
var ethers := JavaScriptBridge.get_interface("ethers")

func shortWalletAddress(walletAddress: String):
  return "{first_part}...{second_part}".format({ "first_part": walletAddress.substr(0, 6), "second_part": walletAddress.substr(38, -1)})

func set_address():
  address_input = ""
  var edit_text = load("res://world/edit_text.tscn").instantiate()
  edit_text.title = "Wallet address"
  edit_text.ok_button_text = "Submit address"
  State.get_tree().root.add_child(edit_text)
  edit_text.popup_centered()
  await edit_text.confirmed
  if(ethers.isAddress(edit_text.input_text.text)):
    address_input = edit_text.input_text.text
    is_valid_address = true
  else:
    is_valid_address = false
    edit_text.queue_free()

func set_amount():
  amount_input = ""
  var edit_text = load("res://world/edit_text.tscn").instantiate()
  edit_text.title = "Token amount"
  edit_text.ok_button_text = "Submit amount"
  State.get_tree().root.add_child(edit_text)
  edit_text.popup_centered()
  await edit_text.confirmed
  if edit_text.input_text.text.is_valid_float() or edit_text.input_text.text.is_valid_int():
    amount_input = edit_text.input_text.text
    is_valid_amount = true
  else:
    is_valid_amount = false
    edit_text.queue_free()