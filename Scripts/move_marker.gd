extends Node3D

const UiColorChanger = preload("uid://b5ok34ueyf7g5")


func _ready() -> void:
	var child = get_child(0)
	var material: StandardMaterial3D = child.get_surface_override_material(0)
	material.albedo_color = UiColorChanger.new_color
