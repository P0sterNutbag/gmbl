extends VBoxContainer


func _ready() -> void:
	for child in get_children():
		child.tree_exited.connect(_on_child_tree_exited)
	var show_messages = ConfigManager.file.get_value("tutorial", "show_messages", true)
	if !show_messages:
		for child in get_children():
			child.queue_free()


func _on_child_tree_exited():
	if get_child_count() > 0:
		return
	ConfigManager.file.set_value("tutorial", "show_messages", false)
	ConfigManager.save()
