extends Label

var score = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_box_destroyed():
	if score == 1:
		var parent_scene = get_parent()
		var ball = parent_scene.get_parent().find_child("Ball")
		score -= 1

		ball.game_over()
	if score > 1:
		score -= 1   
		text = "Score: %s" % score
