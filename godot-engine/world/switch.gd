extends Node3D

@export var scene_to_load: String

# Called when the node enters the scene tree for the first time.
func _ready():
	State.started_packtingo.connect(_on_change_to_packtingo.bind())
	

func _on_change_to_packtingo():
	var loading_scene = preload("res://loading_scene.tscn").instantiate()
	var world = get_child(-1, true)
	remove_child(world)
	world.call_deferred("free")
	scene_to_load = "res://packtingo/packtingo.tscn"
	add_child(loading_scene)
