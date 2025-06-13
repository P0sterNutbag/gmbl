extends Area3D

var has_player: bool
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D


func _process(delta: float) -> void:
	if has_player:
		if Input.is_action_just_pressed("interact"):
			leave_encounter()
			SceneManager.start_scene_transition(Globals.overworld)


func leave_encounter() -> void:
	Globals.overworld.kill_encounter = true
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.state != enemy.states.dead:
			Globals.overworld.kill_encounter = false
			continue
	SceneManager.start_scene_transition(Globals.overworld)


func _on_body_entered(body: Node3D) -> void:
	has_player = true
	mesh_instance_3d.get_active_material(0).cull_mode = 1
	Globals.ui.exit_area.show()


func _on_body_exited(body: Node3D) -> void:
	has_player = false
	mesh_instance_3d.get_active_material(0).cull_mode = 0
	Globals.ui.exit_area.hide()
