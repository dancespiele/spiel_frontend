class_name DestroyBox

var get_play_destroy_the_box_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_play_destroy_the_box_callback")));
var get_wait_link_tx_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_wait_link_tx_callback")))
var get_wait_roll_dice_tx_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_wait_roll_dice_tx_callback")))
var get_box_to_destroy_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_box_to_destroy_callback")));
var get_error_box_to_destroy_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_error_box_to_destroy_callback")));
var get_approve_link_token_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_approve_link_token_callback")))
var get_error_approve_token_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_error_approve_token_callback")))
var get_approve_roll_dice_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_approve_roll_dice_callback")))
var get_error_approve_roll_dice_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_error_approve_roll_dice_callback")))
var console := JavaScriptBridge.get_interface("console")
var window := JavaScriptBridge.get_interface("window")

var link_token_address := "0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846"
var destroy_box_address := "0xdb7124CA606C8353582448403e1C4B8beb98d17b"
var fee_destroy_ball := "500000000000000000"
var signer: JavaScriptObject
var tx_hash: String
var token: String
var error_message: String

func get_random_box():
	window.provider.getSigner().then(get_play_destroy_the_box_callback_ref)

func get_play_destroy_the_box_callback(args):
	if args[0]:
		signer = args[0]
		token = "LINK"
		Utils.add_dialogue("approve_token", Utils.dialogueUrl.feedback)
		window.link_token_contract.connect(signer).approve(
			destroy_box_address, fee_destroy_ball
		).then(
			get_wait_link_tx_callback_ref
		).catch(
      get_error_approve_token_callback_ref
		)

func get_wait_link_tx_callback(args):
	args[0].wait().then(get_approve_link_token_callback_ref)

func get_error_approve_token_callback(args):
	error_message = args[0].message
	Utils.add_dialogue("destroy_box_approve_error", Utils.dialogueUrl.error_handle)
	
func get_approve_link_token_callback(_args):
	Utils.add_dialogue("sign_contract", Utils.dialogueUrl.feedback)
	window.destroy_box_contract.connect(signer).rollDice().then(
		get_wait_roll_dice_tx_callback_ref
	).catch(
		get_error_approve_roll_dice_callback_ref
	)

func get_error_approve_roll_dice_callback(args):
	error_message = args[0].message
	Utils.add_dialogue("destroy_box_sign_error", Utils.dialogueUrl.error_handle)

func get_wait_roll_dice_tx_callback(args):
	args[0].wait().then(get_approve_roll_dice_callback_ref)

func get_approve_roll_dice_callback(args):
	tx_hash = args[0].hash
	Utils.add_dialogue("transaction_sent", Utils.dialogueUrl.feedback)
	await State.get_tree().create_timer(3).timeout
	Utils.add_dialogue("wait_game", Utils.dialogueUrl.feedback)
	await State.get_tree().create_timer(30).timeout
	window.destroy_box_contract.connect(signer).boxToDestroy().then(
		get_box_to_destroy_callback_ref
	).catch(get_error_box_to_destroy_callback_ref)

func get_box_to_destroy_callback(args):
	window.box_to_destroy = window.Number(args[0])
	start_packtingo()

func get_error_box_to_destroy_callback(args):
	error_message = args[0].message
	Utils.add_dialogue("destroy_box_error_get_number", Utils.dialogueUrl.error_handle)

func start_packtingo():
	State.started_packtingo.emit()