extends VBoxContainer

var config = ConfigFile.new()
var path = "user://config.cfg"


func _ready() -> void:
	for child in get_children():
		child.tree_exited.connect(_on_child_tree_exited)
	var err = config.load(path)
	if err != OK:
		return
	var show_messages = config.get_value("tutorial", "show_messages")
	if !show_messages:
		for child in get_children():
			child.queue_free()


func _on_child_tree_exited():
	if get_child_count() > 0:
		return
	var _err = config.load(path)
	config.set_value("tutorial", "show_messages", false)
	config.save(path)
