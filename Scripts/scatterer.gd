@tool
extends Node3D

@export var scenes: Array[PackedScene]
@export var count := 100
@export var area_size := Vector2(50, 50)
@export var min_size := 1.0
@export var max_size := 1.0
@export var rotate_x: bool
@export var rotate_y: bool
@export var rotate_z: bool
@export var scatter_button := false : set = _on_scatter_button_pressed


func _on_scatter_button_pressed(value):
	if not Engine.is_editor_hint():
		return
	
	if !value:
		return
	
	if scenes.size() == 0:
		return

	var container = Node3D.new()
	add_child(container)
	var inst = scenes[0].instantiate()
	container.name = inst.name + "s"
	inst.queue_free()

	var scene_owner = get_tree().edited_scene_root
	container.set_owner(scene_owner)

	randomize()
	for i in count:
		var pc = scenes[randi() % scenes.size()-1]
		var bush = pc.instantiate()
		var pos = Vector3(randf_range(-area_size.x / 2, area_size.x / 2), 0.0, randf_range(-area_size.y / 2, area_size.y / 2))
		bush.position = pos
		if rotate_x: bush.rotation.x = randf_range(0, TAU)
		if rotate_y: bush.rotation.y = randf_range(0, TAU)
		if rotate_z: bush.rotation.z = randf_range(0, TAU)
		bush.scale = Vector3.ONE * randf_range(min_size, max_size)
		container.add_child(bush)
		bush.set_owner(scene_owner) 

	# Reset the button
	scatter_button = false
	notify_property_list_changed()


func _get_property_list():
	return [
		{
			"name": "scatter_button",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_EDITOR,
		}
	]
