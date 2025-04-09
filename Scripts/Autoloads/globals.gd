extends Node

var player
var ui
var noise_controller


func create_instance(scene: PackedScene, position: Vector3 = Vector3.ZERO, parent: Node = get_tree().current_scene):
	var instance = scene.instantiate()
	parent.add_child.call_deferred(instance)
	instance.set_deferred("global_position", position)
	return instance
