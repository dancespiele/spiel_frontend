extends StaticBody3D

signal destroyed

var win_game_label: Node
var score_label: Node
var console = JavaScriptBridge.get_interface("console")

# Called when the node enters the scene tree for the first time.
func _ready():
	var parent_scene = get_parent()
	win_game_label = parent_scene.get_node("UserInterface/WinGame")
	score_label = parent_scene.get_node("UserInterface/Points")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func send_score():
	var auth = Auth.new()
	var score = score_label.score;
	var score_body = JSON.stringify({"score": score});

	var token = auth.get_token()

	Utils.request(self, self._create_score_complete,
	["Content-Type: application/json", "Authorization: {auth}".format({"auth": token})],
	 "http://127.0.0.1:3100/score",
	HTTPClient.METHOD_POST, 
	score_body)

func destroy():
	win_game_label.show()
	send_score()
	await get_tree().create_timer(3).timeout
	destroyed.emit()
	queue_free()

func _create_score_complete(_result, _response_code, _headers, body):
	var response = JSON.parse_string(body.get_string_from_utf8())

	console.log(response)