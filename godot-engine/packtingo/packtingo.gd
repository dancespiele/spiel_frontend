extends Node3D

var window = JavaScriptBridge.get_interface("window")
var console = JavaScriptBridge.get_interface("console")
@export var scene_to_load: String

# Called when the node enters the scene tree for the first time.
func _ready():

	draw_box(4, 5, -3, 6)

	if !$Switch/Ball.screen_exited.is_connected(_on_change_to_world.bind()):
		$Switch/Ball.screen_exited.connect(_on_change_to_world.bind());

	if !$Switch/UserInterface/Points.game_over.is_connected(_on_change_to_world.bind()):
		$Switch/UserInterface/Points.game_over.connect(_on_change_to_world.bind())
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func draw_box(box_number_x: int, box_number_z: int, box_position_z: int, box_position_x: int):
	var box_to_destroy = 0

	for i in range(box_number_x):
		for x in range(box_number_z):
			box_to_destroy += 1

			var standard_box_scene: Node
			var winner_box_scene: Node	

			if box_to_destroy == window.box_to_destroy:
				winner_box_scene = preload("res://packtingo/box_to_destroy.tscn").instantiate()
				winner_box_scene.scale = Vector3(1, 1, 1)
				box_position_z = add_box(winner_box_scene, box_position_x, box_position_z)

				if !winner_box_scene.destroyed.is_connected(_on_change_to_world.bind()):
					winner_box_scene.destroyed.connect(_on_change_to_world.bind())
				
			else:
				standard_box_scene = preload("res://packtingo/box.tscn").instantiate()
				standard_box_scene.scale = Vector3(2, 2, 2)
				box_position_z = add_box(standard_box_scene, box_position_x, box_position_z)

				if !standard_box_scene.destroyed.is_connected($Switch/UserInterface/Points._on_box_destroyed.bind()):
					standard_box_scene.destroyed.connect($Switch/UserInterface/Points._on_box_destroyed.bind())
		
		box_position_z = -3
		box_position_x = box_position_x - 1

func add_box(box_scene: Node, box_position_x: int, box_position_z: int):
	$Switch.add_child(box_scene)

	box_position_z = box_position_z + 1

	box_scene.position = Vector3(box_position_x, -1, box_position_z)
	
	return box_position_z

func _on_change_to_world():
	var load_scene = preload("res://loading_scene.tscn").instantiate()
	var packtingo = get_child(-1, true)
	remove_child(packtingo)
	packtingo.call_deferred("free")
	scene_to_load = "res://main_scene.tscn"
	add_child(load_scene)
