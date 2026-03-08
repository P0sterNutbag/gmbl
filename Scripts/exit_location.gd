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
	var factions = []
	var location_data = Globals.overworld.current_encounter.location_data
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.state != enemy.states.dead:
			if !factions.has(enemy.faction):
				factions.append(enemy.faction)
	var battle = BattleManager.get_battle(Globals.overworld.current_encounter)
	if battle:
		for location in battle.all_locations:
			var data = location.location_data
			var population = enemies.filter(func(a): return a.state != a.states.dead and a.faction == data.faction).size()
			data.population = population
	else:
		location_data.population = enemies.filter(func(a): return a.state != a.states.dead and a.faction == location_data.faction).size()
	if factions.size() == 0:
		location_data.faction = FactionManager.factions.no_faction
		if battle: 
			battle.end_battle(Globals.overworld.current_encounter)
	elif factions.size() == 1:
		if battle:
			var winner = battle.all_locations.filter(func(a): return a.location_data.population > 0)[0]
			battle.end_battle(winner)
	var player_vector: Vector3 = (get_parent().global_position - Globals.player.global_position).normalized().rotated(Vector3.UP, -rotation.y)
	Globals.overworld.player_spawn_vector = player_vector
	SceneManager.start_scene_transition(Globals.overworld)


func _on_body_entered(_body: Node3D) -> void:
	has_player = true
	mesh_instance_3d.get_active_material(0).cull_mode = 1
	Globals.ui.exit_area.show()


func _on_body_exited(_body: Node3D) -> void:
	has_player = false
	mesh_instance_3d.get_active_material(0).cull_mode = 0
	Globals.ui.exit_area.hide()
