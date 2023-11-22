extends CharacterBody3D


var speed = 5.0
var jump_impulse = 20
var target_velocity= Vector3.ZERO
var fall_acceleration= 75.0
@onready var dialogue_bot: DialogueLabel = $DialogueBot
@onready var actionable_finder: Area3D = $Direction/ActionableFinder
@onready var resource = load("res://dialogue/bot_service.dialogue") as DialogueResource
var address: String

const Balloon = preload("res://dialogue/balloon.tscn")

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
	var actionable = actionable_finder.get_overlapping_areas()

	if actionable.size() > 0 and Input.is_action_pressed("dialogue"):
		create_balloon()

func create_balloon():
	var balloon = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(resource, "main_menu")
