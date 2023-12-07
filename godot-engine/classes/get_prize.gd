class_name GetPrize

var get_prize_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_prize_callback")))
var get_prize_tx_wait_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_prize_tx_wait_callback")))

var window := JavaScriptBridge.get_interface("window")
var tx_hash: String

func get_prize(prize):
  Utils.add_dialogue("sign_contract", Utils.dialogueUrl.feedback)
  window.request_prize_contract.connect(window.signer).mintNft(prize.requestId).then(get_prize_callback_ref)

func get_prize_callback(args):
  args[0].wait().then(get_prize_tx_wait_callback_ref)

func get_prize_tx_wait_callback(args):
  tx_hash = args[0].hash
  Utils.add_dialogue("prize_minted", Utils.dialogueUrl.feedback)


