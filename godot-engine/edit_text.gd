extends AcceptDialog

@onready var input_text: LineEdit = $AddressEdit


func _ready() -> void:
	register_text_enter(input_text)

func _on_about_to_popup() -> void:
	input_text.call_deferred("grab_focus")
	input_text.call_deferred("select_all")

func _on_close_requested() -> void:
	emit_signal("confirmed")
