extends Node3D

@export_multiline var text: String
@onready var label_3d: Label3D = $StaticBody3D/MeshInstance3D2/Label3D


func _ready() -> void:
	label_3d.text = text
	label_3d.hide()


func _on_area_3d_area_entered(_area: Area3D) -> void:
	label_3d.show()


func _on_area_3d_area_exited(_area: Area3D) -> void:
	label_3d.hide()
