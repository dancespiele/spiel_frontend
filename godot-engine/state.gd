extends Node 

signal started_packtingo

var list_price = ListPrice.new()

var send_tokens = SendTokens.new()

var destroy_box = DestroyBox.new()

var avax_tokens = AvaxTokens.new()

var utils = Utils.new()

func ask_for_price_list():
	list_price.get_price_list()

func ask_for_address():
	await utils.set_address()

func ask_for_amount():
	await utils.set_amount()

func ask_wrap_token():
	avax_tokens.wrap_token(utils.amount_input)

func ask_unwrap_token():
	avax_tokens.unwrap_token(utils.amount_input)

func calc_fees():
	send_tokens.get_calc_fees(utils.address_input, utils.amount_input)

func ask_send_tokens():
	send_tokens.start_transaction()

func play_destroy_the_box():
	destroy_box.get_random_box()

