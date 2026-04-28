extends Area3D

@export var overworld_point: String
var has_player: bool
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D


func _process(_delta: float) -> void:
	if has_player:
		if Input.is_action_just_pressed("select"):
			leave_encounter()


func leave_encounter() -> void:
	var player_vector: Vector3 = (get_parent().global_position - Globals.player.global_position).normalized().rotated(Vector3.UP, -rotation.y)
	Globals.overworld.player_spawn_vector = player_vector
	get_tree().current_scene.update_location_data()
	SceneManager.start_scene_transition(Globals.overworld, false, false, true)


func _on_body_entered(_body: Node3D) -> void:
	has_player = true
	mesh_instance_3d.get_active_material(0).cull_mode = 1
	Globals.ui.set_tooltip_custom("Exit Area")
	#Globals.ui.exit_area.show()


func _on_body_exited(_body: Node3D) -> void:
	has_player = false
	mesh_instance_3d.get_active_material(0).cull_mode = 0
	Globals.ui.hide_tooltip()
