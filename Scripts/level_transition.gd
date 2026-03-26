extends Area3D

@export var target_level: Variant


func _on_body_entered(_body: Node3D) -> void:
	SceneManager.start_scene_transition(target_level)
