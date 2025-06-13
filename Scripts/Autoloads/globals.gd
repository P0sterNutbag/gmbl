extends Node

var player
var ui: CanvasLayer
var noise_controller
var overworld: Node3D
var particle_manager: Node


func _ready() -> void:
	particle_manager = Node.new()
	particle_manager.name = "ParticleManager"
	add_child(particle_manager)


func create_instance(scene: PackedScene, position: Vector3 = Vector3.ZERO, parent: Node = get_tree().current_scene):
	var instance = scene.instantiate()
	parent.add_child.call_deferred(instance)
	instance.set_deferred("global_position", position)
	return instance


func create_particle(particle_scene: PackedScene, position: Vector3, parent: Node = null) -> Node:
	if particle_manager == null:
		return null
	var particle = particle_scene.instantiate()
	particle_manager.add_child.call_deferred(particle)
	particle.set_deferred("global_position", position)
	if parent != null:
		particle.set_deferred("global_transform", parent.global_transform)
	return particle


func change_scene(new_scene: PackedScene, delete_current: bool) -> void:
	get_tree().root.remove_child(get_tree().current_scene)
	await get_tree().create_timer(0.1).timeout
	var inst = new_scene.instantiate()
	get_tree().root.add_child(inst)
	get_tree().current_scene = inst
