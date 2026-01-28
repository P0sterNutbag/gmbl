extends Area3D

@export var overworld_point: String
var has_player: bool
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D


func _process(_delta: float) -> void:
	if has_player:
		if Input.is_action_just_pressed("select"):
			leave_encounter()
			SceneManager.start_scene_transition(Globals.overworld)


func leave_encounter() -> void:
	var enemy_count: int = 0
	if Globals.overworld.current_encounter.get_node_or_null("StartingSquadSpawner"):
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy.is_starting_squad and enemy.state != enemy.states.dead and enemy.state != enemy.states.standby:
				enemy_count += 1
	else:
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy.state != enemy.states.dead and enemy.state != enemy.states.standby:
				enemy_count += 1
	Globals.overworld.current_encounter.location_data.population = enemy_count
	var player_vector: Vector3 = (get_parent().global_position - Globals.player.global_position).normalized().rotated(Vector3.UP, -rotation.y)
	Globals.overworld.player_spawn_vector = player_vector
	#Globals.overworld.player_place = NodePath(overworld_point)
	SceneManager.start_scene_transition(Globals.overworld)


func _on_body_entered(_body: Node3D) -> void:
	has_player = true
	mesh_instance_3d.get_active_material(0).cull_mode = 1
	Globals.ui.exit_area.show()


func _on_body_exited(_body: Node3D) -> void:
	has_player = false
	mesh_instance_3d.get_active_material(0).cull_mode = 0
	Globals.ui.exit_area.hide()
