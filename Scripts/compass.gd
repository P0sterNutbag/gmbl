extends Control

var compass_object: Node3D
var quests: Array[Quest]
var quest_marker = preload("res://Scenes/UI/quest_marker.tscn")
@onready var compass: ColorRect = $ColorRect
@onready var markers: Control = $Markers


func _ready() -> void:
	await get_tree().process_frame
	set_quest_markers()
	if get_tree().current_scene.name == "Overworld":
		compass_object = Globals.player.get_node_or_null("CameraAnchor")
	else:
		compass_object = Globals.player


func _process(_delta: float) -> void:
	if !visible:
		return
	# compass movement
	var cam_rot = rad_to_deg(compass_object.rotation.y)
	compass.position.x = compass.size.x * ((cam_rot / 360.0) + 0.5) - compass.size.x - 70
	# Position quest marker
	for i in quests.size():
		var quest = quests[i]
		var marker = markers.get_child(i)
		if quest.completed:
			marker.hide()
			continue
		var quest_object = null
		if get_tree().current_scene == Globals.overworld:
			for location in get_tree().get_nodes_in_group("location"):
				if quest.location.to_lower() == location.point_of_interest.title.to_lower():
					quest_object = location
		else:
			if !quest.target_node:
				return
			quest_object = quest.target_node
		var player_forward = -compass_object.global_transform.basis.z.normalized()
		player_forward.y = 0
		var to_quest = (quest_object.global_transform.origin - compass_object.global_transform.origin).normalized()
		to_quest.y = 0
		var dot_product = clamp(player_forward.dot(to_quest), -1.0, 1.0)
		var cross = -player_forward.cross(to_quest).y  # positive = to the right, negative = to the left
		var angle = atan2(cross, dot_product)
		var angle_deg = rad_to_deg(angle)
		var fov = 90.0  # adjust as needed
		var normalized = clamp(angle_deg / (fov / 2.0), -1.0, 1.0)
		var half_width = size.x / 2.0
		marker.position.x = half_width + (normalized * half_width) - 12
		marker.position.x = clamp(marker.position.x, -12, size.x - 12)


func set_quest_markers():
	quests.clear()
	for child in markers.get_children():
		child.queue_free()
	if get_tree().current_scene == Globals.overworld:
		quests = PlayerStats.quests.filter(func(i): return i.location != "")
	else:
		quests = PlayerStats.quests.filter(func(i): 
			var quest_location = i.location
			var encounter_location = Globals.overworld.current_encounter.point_of_interest.title
			return quest_location == encounter_location)
	for quest in quests:
		var inst = quest_marker.instantiate()
		markers.add_child(inst)
