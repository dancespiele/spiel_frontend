extends Node 

signal started_packtingo

var list_price = ListPrice.new()

var send_tokens = SendTokens.new()

var destroy_box = DestroyBox.new()

func ask_for_price_list():
	list_price.get_price_list()

func ask_for_address():
	await send_tokens.set_address()

func ask_for_amount():
	await send_tokens.set_amount()

func calc_fees():
	send_tokens.get_calc_fees()

func ask_send_tokens():
	send_tokens.start_transaction()

func play_destroy_the_box():
	destroy_box.get_random_box()

