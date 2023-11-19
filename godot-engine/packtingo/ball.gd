extends CharacterBody3D

@export var target_velocity = Vector3.ZERO
@export var initial_position = Vector3.ZERO
@export var total_box = 0
var parent_scene: Node
var lifes_label: Label
var lose_game_label: Label
var win_game_label: Label

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true) # Replace with function body.
	parent_scene = get_parent()
	lifes_label = parent_scene.get_node("UserInterface/Lifes")
	lose_game_label = parent_scene.get_node("UserInterface/LoseGame")
	win_game_label = parent_scene.get_node("UserInterface/WinGame")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if Input.is_action_pressed("start") && target_velocity == Vector3.ZERO:
		target_velocity.x = randf_range(1.0, 3.0) * delta
		target_velocity.z = randf_range(-1.0, 1.0) * delta
		
		initial_position = position
		velocity = target_velocity

	if target_velocity != Vector3.ZERO:
		var current_velocity = velocity
		var collision_object = move_and_collide(current_velocity)

		if collision_object:
			var bounce = current_velocity.bounce(collision_object.get_normal())
			bounce.x = bounce.x + randf_range(-2.0, 2.0) * delta
			velocity = bounce

			var collider = collision_object.get_collider()

			if collider && collider.is_in_group("box"):
				await collider.destroy()
				check_exists_boxes()

func check_exists_boxes():
	for child in parent_scene.get_children():
		if child.is_in_group("box"):
			total_box +=1

	if total_box <= 1:
		win_game_label.show()
		reset_position()
	else:
		total_box = 0


func reset_position():
	target_velocity = Vector3.ZERO
	velocity = target_velocity
	position = initial_position

func exit_screen():
	reset_position()

func _on_visible_notifier_screen_exited():
	if lifes_label.lifes <= 1:
		lose_game_label.show()
		queue_free()
	else:
		exit_screen() # Replace with function body.
  
