extends CharacterBody3D

@export var initial_position = Vector3.ZERO
@export var target_velocity = Vector3.ZERO
@export var speed = 200

func _ready():
	initial_position = position
	set_physics_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var direction = Vector3.ZERO
	var current_position = position

	if initial_position.x != current_position.x:
		current_position.x = initial_position.x

		position = current_position
	
	if Input.is_action_pressed("move_right"):
		direction.z += 1

	if Input.is_action_pressed("move_left"):
		direction.z -= 1

	target_velocity.z = direction.z * speed * delta

	velocity = target_velocity
	
	move_and_slide()



