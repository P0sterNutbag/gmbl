extends Node
var data = {}

var save_dir = "user://"
var save_path = "user://savegame.save"
var resource_path = "user://resources.res"
var saved_resources: SavedResources
signal save
signal load


func _ready() -> void:
	saved_resources = ResourceLoader.load(resource_path)
	if !saved_resources:
		saved_resources = SavedResources.new()
		ResourceSaver.save(saved_resources, resource_path)
	#save_data_to_file()
	#load_data_from_file()


#func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("ui_copy"):
		##save_session_data()
		#save_data_to_file()
	#if Input.is_action_just_pressed("ui_paste"):
		#load_data_from_file()


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
		var resource_dict = {}
		for key in node_data:
			var value = node_data[key]
			if value is Resource:
				resource_dict[key] = value
			elif value is Array:
				var array = SavedArray.new()
				array.array = value
				resource_dict[key] = array
		node_data["path"] = node.get_scene_file_path()
		data[str(node.get_path())] = node_data
		if resource_dict.size() > 0:
			saved_resources.resources[str(node.get_path())] = resource_dict
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	var json_string = JSON.stringify(data)
	save_file.store_line(json_string)
	ResourceSaver.save(saved_resources, resource_path)
	save.emit()


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
		var node = get_tree().root.get_node_or_null(node_path)
		if !node:
			node = load(data[node_path]["path"]).instantiate()
			get_tree().current_scene.add_child(node)
		for node_data in data[node_path]:
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
		if saved_resources.resources.has(node_path):
			for key in saved_resources.resources[node_path]:
				var value = saved_resources.resources[node_path][key]
				if value is SavedArray:
					#node.set(key, value.array)
					var array = node.get(key)
					array.clear()
					array.append_array(value.array)
				else:
					node.set(key, value)
	load.emit()


func delete_save_data() -> void:
	var dir = DirAccess.open("user://")
	dir.remove("savegame.save")
	dir.remove("inventory.res")


func save_file_exists() -> bool:
	if FileAccess.file_exists(save_path):
		return true
	return false
