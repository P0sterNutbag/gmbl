#@tool
extends Node3D

@export var point_at: Node3D
#var max_ammo = ammo


func _process(delta: float) -> void:
	if point_at != null:
		look_at(point_at.global_position)

#
#func _on_shoot():
	##ammo -= 1
	#super._on_shoot()
	#if ammo <= 0:
		#await get_tree().create_timer(2).timeout
		#ammo = max_ammo
