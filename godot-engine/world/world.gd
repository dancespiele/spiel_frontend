extends Node3D

@onready var quick_start_resource = load("res://dialogue/quick_start.dialogue") as DialogueResource

const Balloon = preload("res://dialogue/introduction.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	create_balloon("quick_start", quick_start_resource)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create_balloon(title: String, resource):
	var balloon = Balloon.instantiate()
	add_child(balloon)
	balloon.start(resource, title)