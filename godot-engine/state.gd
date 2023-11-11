extends Node

var address_input: String = ""

func ask_for_address():
  var edit_text = load("res://edit_text.tscn").instantiate()
  get_tree().root.add_child(edit_text)
  edit_text.popup_centered()
  await edit_text.confirmed
  address_input = edit_text.address_edit.text
  edit_text.queue_free()
