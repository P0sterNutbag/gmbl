extends Node

var data = {}
var save_path = "user://savegame.save"


func _ready() -> void:
	pass
	#save_data_to_file()
	#load_data_from_file()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_copy"):
		#save_session_data()
		save_data_to_file()
	if Input.is_action_just_pressed("ui_paste"):
		load_data_from_file()


#func save_session_data():
	#var save_nodes = get_tree().get_nodes_in_group("persist")
	#for node in save_nodes:
		#if !node.has_method("save"):
			#print("persistent node '%s' is missing a save() function, skipped" % node.name)
			#continue
		#var node_data = node.call("save")
		#data[str(node.get_path())] = node_data


func save_data_to_file():
	var save_nodes = get_tree().get_nodes_in_group("persist")
	for node in save_nodes:
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		var node_data = node.call("save")
		data[str(node.get_path())] = node_data
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	var json_string = JSON.stringify(data)
	save_file.store_line(json_string)


func load_data_from_file():
	if not FileAccess.file_exists(save_path):
		return
	var save_file = FileAccess.open(save_path, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		var node_data = json.data
		data = node_data
	for node_path in data.keys():
		for node_data in data[node_path]:
			var node = get_tree().root.get_node_or_null(node_path)
			if !node:
				continue
			var value = data[node_path][node_data]
			if node_data == "pos_x": 
				node.global_position.x = value
			elif node_data == "pos_y": 
				node.global_position.y = value
			elif node_data == "pos_z": 
				node.global_position.z = value
			elif node_data == "rot_y": 
				node.global_rotation.y = value
			else:
				node.set(node_data, value)
