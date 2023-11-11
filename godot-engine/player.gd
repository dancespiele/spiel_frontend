extends CharacterBody3D


var speed = 5.0
var jump_impulse = 20
var target_velocity= Vector3.ZERO
var fall_acceleration= 75.0
@onready var dialogue_bot: DialogueLabel = $DialogueBot
var address: String 

const COLORS = {
	"Bot": "ff5741",
}

func _physics_process(delta):
	var pivot = get_node("Pivot") as Node3D

	var direction = Vector3.ZERO;

	if Input.is_action_pressed("move_right"):
		direction.z += 1.0;

	if Input.is_action_pressed("move_left"): 
		direction.z -= 1.0;

	if Input.is_action_pressed("move_up"):
		direction.x += 1.0;

	if Input.is_action_pressed("move_down"): 
		direction.x -= 1.0;

	if Input.is_action_just_pressed("jump") and is_on_floor():
		target_velocity.y = jump_impulse

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		pivot.look_at(position + direction)

	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	if !is_on_floor():
		target_velocity.y = target_velocity.y - fall_acceleration * delta

	velocity = target_velocity

	move_and_slide()

func _unhandled_input(_event):
	var resource = load("res://dialogue/bot.dialogue") as DialogueResource

	for index in range(0, get_slide_collision_count()):
		var collision_object = get_slide_collision(index)

		if collision_object:
			var collider = collision_object.get_collider() as CharacterBody3D

			if collider and Input.is_action_pressed("dialogue") and collider.is_in_group("bot"):
				DialogueManager.show_example_dialogue_balloon(resource, "main_menu")
