extends Node

var get_list_prices_callback_ref = JavaScriptBridge.create_callback((Callable(self, "get_list_prices_callback")))
var console = JavaScriptBridge.get_interface("console")
var window = JavaScriptBridge.get_interface("window")
var ethers = JavaScriptBridge.get_interface("ethers")

var address_input: String = ""
var prices = {
  "link": "",
  "aave": "",
  "btc": "",
  "eth": "",
  "matic": "",
  "ape": "",
}

func ask_for_price_list():
  var price_list = window.price_list

  price_list.getPriceList().then(get_list_prices_callback_ref)

func get_list_prices_callback(args):
  prices.link = window.Number(ethers.formatUnits(args[0][0], 8))
  prices.aave = window.Number(ethers.formatUnits(args[0][1], 8))
  prices.btc = window.Number(ethers.formatUnits(args[0][2], 8))
  prices.eth = window.Number(ethers.formatUnits(args[0][3], 8))
  prices.matic = window.Number(ethers.formatUnits(args[0][4], 8))
  prices.ape = window.Number(ethers.formatUnits(args[0][5], 8))


func ask_for_address():
  var edit_text = load("res://edit_text.tscn").instantiate()
  get_tree().root.add_child(edit_text)
  edit_text.popup_centered()
  await edit_text.confirmed
  address_input = edit_text.address_edit.text
  edit_text.queue_free()
