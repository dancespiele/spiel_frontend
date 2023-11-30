extends CharacterBody3D

enum GameState {
	PLAY = 0,
	LOSE = 1,
	WIN= 2
}

@export var target_velocity = Vector3.ZERO
@export var initial_position = Vector3.ZERO
@export var total_box = 0
@export var game_state: GameState = GameState.PLAY

var parent_scene: Node
var lifes_label: Label
var lose_game_label: Label

signal screen_exited

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true) # Replace with function body.
	parent_scene = get_parent()
	lifes_label = parent_scene.get_node("UserInterface/Lifes")
	lose_game_label = parent_scene.get_node("UserInterface/LoseGame")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if Input.is_action_pressed("start") && target_velocity == Vector3.ZERO && game_state == GameState.PLAY:
		target_velocity.x = 3 * delta
		target_velocity.z = randf_range(-2.0, 2.0) * delta
		
		initial_position = position
		velocity = target_velocity

	if target_velocity != Vector3.ZERO:
		var current_velocity = velocity
		var collision_object = move_and_collide(current_velocity)

		if collision_object:
			var bounce = current_velocity.bounce(collision_object.get_normal())
			velocity = bounce

			var collider = collision_object.get_collider()

			if collider && collider.is_in_group("box"):
				await collider.destroy()
			
			if collider && collider.is_in_group("back_wall"):
				game_over()

func reset_position():
	target_velocity = Vector3.ZERO
	velocity = target_velocity
	position = initial_position

func game_over():
	game_state = GameState.LOSE
	reset_position()
	lose_game_label.show()
	await get_tree().create_timer(3).timeout
	screen_exited.emit()
	# Replace with function body.
  
