extends Control

var loading_status : int
var progress : Array[float]

@onready var progress_bar : ProgressBar = $ProgressBar
var target_scene_path: String

func _ready() -> void:
	# Request to load the target scene:
	var parent = get_parent()
	target_scene_path = parent.scene_to_load

	ResourceLoader.load_threaded_request(target_scene_path)
	
func _process(_delta: float) -> void:
	# Update the status:
	loading_status = ResourceLoader.load_threaded_get_status(target_scene_path, progress)
	
	# Check the loading status:
	match loading_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = progress[0] * 100 # Change the ProgressBar value
		ResourceLoader.THREAD_LOAD_LOADED:
			# When done loading, change to the target scene:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(target_scene_path))
		ResourceLoader.THREAD_LOAD_FAILED:
			print("Error. Could not load Resource")
