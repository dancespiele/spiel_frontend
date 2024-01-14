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
	var score_body = JSON.stringify({"score": score})

	var token = auth.get_token()

	var endopoint := "{endpoint}/score".format({"endpoint": OS.get_environment("BACKEND_URL")})

	Utils.request(self, self._create_score_complete,
	["Content-Type: application/json", "Authorization: {auth}".format({"auth": token})],
	endopoint,
	HTTPClient.METHOD_POST, 
	score_body)

func destroy():
	var parent = get_parent()
	var ball = parent.find_child("Ball")
	ball.game_state = 2
	ball.reset_position()

	win_game_label.show()
	send_score()
	await get_tree().create_timer(3).timeout
	destroyed.emit()
	queue_free()

func _create_score_complete(_result, _response_code, _headers, body):
	var response = JSON.parse_string(body.get_string_from_utf8())

	console.log(response)