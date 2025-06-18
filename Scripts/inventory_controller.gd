extends HBoxContainer

signal exit


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and visible:
		clear_inventories()
		hide()
		exit.emit()
	if get_child_count() > 1:
		if Input.is_action_just_pressed("ui_right"):
			get_child(1).grab_focus()
		elif Input.is_action_just_pressed("ui_left"):
			get_child(0).grab_focus()


func reset_inventories() -> void:
	for child in get_children():
		child.set_items()


func clear_inventories() -> void:
	for child in get_children():
		child.item_container.delete_children()


func _on_visibility_changed() -> void:
	if visible:
		get_child(get_child_count()-1).grab_focus()
