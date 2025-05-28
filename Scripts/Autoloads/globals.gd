extends Node

var player
var ui: CanvasLayer
var noise_controller
var overworld: Node3D


func create_instance(scene: PackedScene, position: Vector3 = Vector3.ZERO, parent: Node = get_tree().current_scene):
	var instance = scene.instantiate()
	parent.add_child.call_deferred(instance)
	instance.set_deferred("global_position", position)
	return instance


func change_scene(new_scene: PackedScene, delete_current: bool) -> void:
	if delete_current:
		get_tree().change_scene_to_packed(new_scene)
		return
	get_tree().root.remove_child.call_deferred(get_tree().current_scene)
	await get_tree().create_timer(1).timeout
	var inst = new_scene.instantiate()
	get_tree().root.add_child(inst)
	get_tree().current_scene = inst
