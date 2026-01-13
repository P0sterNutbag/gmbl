extends Node

var player
var ui: CanvasLayer
var noise_controller
var overworld: Node3D
var particle_manager: Node
var npc_controller: Node3D
var survival_ui: CanvasLayer
enum crosshairs {standard, dot, none}
var crosshair_type = crosshairs.standard
#const PAUSE_MENU = preload("res://Scenes/UI/pause_menu.tscn")


func _ready() -> void:
	particle_manager = Node.new()
	particle_manager.name = "ParticleManager"
	add_child(particle_manager)
	#crosshair_type = ConfigManager.file.get_value("settings", "crosshair_type", crosshair_type)


func create_instance(scene: PackedScene, position: Vector3 = Vector3.ZERO, parent: Node = get_tree().current_scene):
	var instance = scene.instantiate()
	parent.add_child.call_deferred(instance)
	instance.set_deferred("global_position", position)
	return instance


#func pause_game() -> void:
	#get_tree().paused = true
	#var inst = PAUSE_MENU.instantiate()
	#get_tree().root.add_child(inst)
	#inst.get_child(0).activate()


func create_particle(particle_scene: PackedScene, position: Vector3, parent: Node = null) -> Node:
	if particle_manager == null:
		return null
	var particle = particle_scene.instantiate()
	particle_manager.add_child.call_deferred(particle)
	particle.set_deferred("global_position", position)
	if parent != null:
		particle.set_deferred("global_transform", parent.global_transform)
	#if particle is GPUParticles3D:
	particle.emitting = true
	return particle


func change_scene(new_scene: PackedScene, delete_current: bool) -> void:
	get_tree().root.remove_child(get_tree().current_scene)
	await get_tree().create_timer(0.1).timeout
	var inst = new_scene.instantiate()
	get_tree().root.add_child(inst)
	get_tree().current_scene = inst


func get_weighted_index(array: Array) -> int:
	var sum = 0
	for i in array.size():
		sum += array[i].spawn_chance
	var rand_num = randi_range(0, sum)
	var current_num = 0
	for i in array.size():
		current_num += array[i].spawn_chance
		if rand_num <= current_num:
			return i
	return -1


func get_heightmap_position(pos: Vector3) -> float:
	var terrain = get_tree().root.get_child(-1).get_node("Terrain")
	var height = terrain.get_data().get_height_at(pos.x, pos.z)
	return height


func find_item(items: Array, item_name: String) -> Resource:
	for i in items:
		if i != null and (i.resource_name == item_name or i.title.to_lower() == item_name.to_lower()):
			return i
	return null


func get_dot(from_node: Node3D, to_node: Node3D) -> float:
	var forward = from_node.global_transform.basis.z.normalized()
	var to = (to_node.global_transform.origin - from_node.global_transform.origin).normalized()
	return forward.dot(to)
