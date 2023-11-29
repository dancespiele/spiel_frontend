extends Label

var score = 4

signal game_over

var console = JavaScriptBridge.get_interface("console")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_box_destroyed():
	if score == 1:
		var parent_scene = get_parent()
		var lose_game_label = parent_scene.get_node("LoseGame")

		score -= 1
		lose_game_label.show()
		await get_tree().create_timer(2).timeout
		game_over.emit()
	
	if score > 1:
		score -= 1   
		text = "Score: %s" % score
