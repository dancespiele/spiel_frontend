extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	draw_box(4, 5, -3, 6)

	if !$Ball/VisibleNotifier.screen_exited.is_connected($UserInterface/Lifes._on_life_lost.bind()):
		$Ball/VisibleNotifier.screen_exited.connect($UserInterface/Lifes._on_life_lost.bind());
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func draw_box(box_number_x: int, box_number_z: int, box_position_z: int, box_position_x: int):
	for i in range(box_number_x):
		for x in range(box_number_z):
			var box_scene = preload("res://packtingo/box.tscn").instantiate()

			add_child(box_scene)

			box_position_z = box_position_z + 1

			box_scene.position = Vector3(box_position_x, -1, box_position_z)
			box_scene.scale = Vector3(2, 2, 2)

			if !box_scene.destroyed.is_connected($UserInterface/Points._on_box_destroyed.bind()):
				box_scene.destroyed.connect($UserInterface/Points._on_box_destroyed.bind())
		
		box_position_z = -3
		box_position_x = box_position_x - 1
