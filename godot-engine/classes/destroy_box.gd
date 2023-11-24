class_name DestroyBox

var get_play_destroy_the_box_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_play_destroy_the_box_callback")));
var get_wait_link_tx_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_wait_link_tx_callback")))
var get_wait_roll_dice_tx_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_wait_roll_dice_tx_callback")))
var get_box_to_destroy_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_box_to_destroy_callback")));
var get_approve_link_token_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_approve_link_token_callback")))
var get_approve_roll_dice_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_approve_roll_dice_callback")))
var console := JavaScriptBridge.get_interface("console")
var window := JavaScriptBridge.get_interface("window")

var link_token_address := "0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846"
var destroy_box_address := "0xdb7124CA606C8353582448403e1C4B8beb98d17b"
var fee_destroy_ball := "80000000000000000"
var signer: JavaScriptObject

func get_random_box():
	window.provider.getSigner().then(get_play_destroy_the_box_callback_ref)

func get_play_destroy_the_box_callback(args):
	if args[0]:
		signer = args[0]
		window.link_token_contract.connect(signer).approve(destroy_box_address, fee_destroy_ball).then(get_wait_link_tx_callback_ref)

func get_wait_link_tx_callback(args):
	args[0].wait().then(get_approve_link_token_callback_ref)
	
func get_approve_link_token_callback(_args):
	window.destroy_box_contract.connect(signer).rollDice().then(get_wait_roll_dice_tx_callback_ref)

func get_wait_roll_dice_tx_callback(args):
	args[0].wait().then(get_approve_roll_dice_callback_ref)

func get_approve_roll_dice_callback(args):
	console.log(args[0])
	await State.get_tree().create_timer(30).timeout
	window.destroy_box_contract.connect(signer).boxToDestroy().then(get_box_to_destroy_callback_ref)

func get_box_to_destroy_callback(args):
	window.box_to_destroy = window.Number(args[0])
	start_packtingo()

func start_packtingo():
	State.started_packtingo.emit()