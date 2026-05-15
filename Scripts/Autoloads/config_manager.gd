extends Node

var file = ConfigFile.new()
var path = "user://config.cfg"
signal settings_changed


func _ready() -> void:
	var err = file.load(path)
	if err != OK:
		file.save(path)


func save() -> void:
	file.save(path)
	settings_changed.emit()
