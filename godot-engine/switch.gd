extends Node3D
var	packtingo_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	packtingo_scene = preload("res://packtingo/packtingo.tscn").instantiate()
	State.started_packtingo.connect(_on_change_to_packtingo.bind())
	

func _on_change_to_packtingo():
	$World.call_deferred("free")
	add_child(packtingo_scene)

func _on_change_to_world():
	remove_child(packtingo_scene)
	packtingo_scene.call_deferred("free")
	add_child($World)
