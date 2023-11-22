extends Label

var score = 4

signal game_over

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_box_destroyed():
	score -= 1   
	text = "Score: %s" % score

	if score == 0:
		game_over.emit()
