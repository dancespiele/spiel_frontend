extends AcceptDialog

@onready var address_edit: LineEdit = $AddressEdit

func _ready() -> void:
	register_text_enter(address_edit)

func _on_about_to_popup() -> void:
	address_edit.text = "Address"
	address_edit.call_deferred("grab_focus")
	address_edit.call_deferred("select_all")



func _on_close_requested() -> void:
	emit_signal("confirmed")
