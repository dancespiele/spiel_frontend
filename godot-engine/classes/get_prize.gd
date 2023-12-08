class_name GetPrize

var get_prize_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_prize_callback")))
var get_prize_tx_wait_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_prize_tx_wait_callback")))

var window := JavaScriptBridge.get_interface("window")
var tx_hash: String
var prize

func get_prize(prize_arg):
  prize = prize_arg
  Utils.add_dialogue("sign_contract", Utils.dialogueUrl.feedback)
  window.request_prize_contract.connect(window.signer).mintNft(prize.request_id).then(get_prize_callback_ref)

func get_prize_callback(args):
  args[0].wait().then(get_prize_tx_wait_callback_ref)

func get_prize_tx_wait_callback(args):
  tx_hash = args[0].hash
  var endpoint = "https://spielcrypto.xyz:3100/pize/{prize_id}".format({"prize_id": prize.id})
  var auth = Auth.new()
  var token = auth.get_token()

  Utils.request(
    State,
    self._request_update_prize_completed,
    ["Content-Type: application/json", "Authorization: {auth}".format({"auth": token})],
    endpoint,
    HTTPClient.METHOD_PUT,
  )
  
  Utils.add_dialogue("prize_minted", Utils.dialogueUrl.feedback)

func _request_update_prize_completed(_result, _response_code, _headers, _body):
  Utils.add_dialogue("prize_minted", Utils.dialogueUrl.feedback)