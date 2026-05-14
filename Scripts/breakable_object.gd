extends Node3D

@export var destory_particle: PackedScene
@onready var rigid_body_3d: RigidBody3D = $RigidBody3D


func _on_health_component_death() -> void:
	var inst = destory_particle.instantiate()
	get_tree().current_scene.add_child(inst)
	inst.global_position = rigid_body_3d.global_position
	inst.emitting = true
	queue_free()
