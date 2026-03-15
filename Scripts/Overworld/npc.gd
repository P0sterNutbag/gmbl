extends CharacterBody3D

enum guns {shotgun, ak47, sniper, pistol}
enum states {walk, chase, battle, dead}
@export var gun_index: guns
@export var destination: Location
var state = states.walk
var speed := 2
var walk_speed := 2
var run_speed := 3
var path_index := 0
var max_enemies := 6
var min_enemies := 3
var save_population: int = -1
var chase_player: bool = true
var can_move: bool
var original_position: Vector3
var original_rotation: Vector3
var target: Node3D
var destination_path: NodePath
@export var faction: FactionManager.factions = FactionManager.factions.no_faction
var guns_dict: Dictionary = {
	0 : [preload("res://Scenes/Guns/shotgun.tscn"), preload("res://Scenes/Items/Guns/shotgun.tscn")],
	1 : [preload("res://Scenes/Guns/ak47.tscn"), preload("res://Scenes/Items/Guns/ak47.tscn")],
	2 : [preload("res://Scenes/Guns/sniper.tscn"), preload("res://Scenes/Items/Guns/sniper_rifle.tscn")],
	3 : [preload("res://Scenes/Guns/pistol.tscn"), preload("res://Scenes/Items/Guns/pistol.tscn")],
}
@onready var detection: Node3D = $Detection
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $EnemyModel/PersonAnimated/AnimationPlayer
@onready var gun_holder: Node3D = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D
@onready var location: Location = $Location
@onready var enemy_model: Node3D = $EnemyModel


func _enter_tree() -> void:
	can_move = true
	await get_tree().create_timer(0.1).timeout
	get_tree().call_group("overworld npcs", "set_detection_targets")


func _ready() -> void:
	var gun = guns_dict[gun_index][0].instantiate()
	gun_holder.add_child(gun)
	location.location_data.population = randi_range(min_enemies, max_enemies)
	location.encounter_started.connect(_on_encounter_started)
	location.encounter_ended.connect(_on_encounter_ended)
	location.remove_from_group("persist")
	SaveController.load.connect(_on_load)
	await get_tree().process_frame
	if location.dialogue_tree != null:
		location.dialogue_tree.npc_style = enemy_model.current_style
		var faction_name = FactionManager.faction_data[faction].name
		if faction_name[-1] == "s":
			faction_name[-1] = ""
		location.dialogue_tree.npc_name = faction_name + " " + location.dialogue_tree.npc_name
		location.title = faction_name + " " + location.title
	location.location_data.faction = faction
	original_position = global_position
	original_rotation = global_rotation
	if destination:
		navigation_agent.set_target_position(destination.global_position)


func _process(_delta: float) -> void:
	match (state):
		states.walk:
			speed = walk_speed
			# detect player
			target = detection.get_visible_target()
			if target:
				state = states.chase
				#if target == Globals.player and !chase_player:
					#state = states.walk
			# animate
			if velocity != Vector3.ZERO:
				anim_player.play("Walk")
			else:
				anim_player.play("Idle")
		
		states.chase:
			speed = run_speed
			# stop chasing player
			if target == Globals.player:
				if (UiController.is_canvas_layer_open(Globals.ui) or !chase_player):
					detection.targets.erase(target)
					state = states.walk
			elif target.state == target.states.dead:
				detection.targets.erase(target)
				state = states.walk
			if global_position.distance_to(target.global_position) > detection.detection_range:
				state = states.walk
			# chase after target
			if detection.can_see_target(target):
				navigation_agent.set_target_position(target.global_position)
			else:
				if destination:
					navigation_agent.set_target_position(destination.global_position)
					state = states.walk
				else:
					navigation_agent.set_target_position(original_position)
					state = states.walk
			# animate
			if velocity != Vector3.ZERO:
				anim_player.play("Run")
			else:
				anim_player.play("Idle")
		
		states.battle:
			velocity = Vector3.ZERO
			anim_player.play("IdleAim")


func _physics_process(delta: float) -> void:
	# move towards destination
	if navigation_agent.target_position != Vector3.ZERO and can_move:
		match state:
			states.walk:
				follow_path(speed)
			states.chase:
				follow_path(speed)
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func follow_path(spd: float = walk_speed):
	if navigation_agent.is_navigation_finished():
		return
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var path_velocity = global_position.direction_to(next_path_position) * spd
	velocity = Vector3(path_velocity.x, velocity.y, path_velocity.z)
	look_at_position(next_path_position)


func look_at_position(pos: Vector3):
	if pos == global_position:
		return
	var target_pos = pos
	target_pos.y = global_position.y
	look_at(target_pos, Vector3.UP)


func set_detection_targets():
	detection.targets.clear()
	for npc in get_tree().get_nodes_in_group("overworld npcs"):
		if FactionManager.get_faction_relation(faction, npc.faction) <= -1.0:
			detection.targets.append(npc)
	if Globals.player and chase_player and FactionManager.get_faction_relation(faction, PlayerStats.faction) <= -1.0 and !UiController.is_canvas_layer_open(Globals.ui):
		detection.targets.append(Globals.player)


func return_to_path() -> void:
	state = states.walk
	location.can_transition = true
	if destination:
		navigation_agent.set_target_position(destination.global_position)


func die():
	state = states.dead
	set_collision_layer_value(1, false)
	location.queue_free()
	velocity = Vector3.ZERO
	set_process(false)
	set_physics_process(false)
	anim_player.play("Die")
	if !is_inside_tree():
		await tree_entered
	#UiController.close_interface(Globals.ui.dialogue)
	await get_tree().create_timer(5).timeout
	queue_free()


func save() -> Dictionary:
	var dic = {"pos_x": global_position.x,
		"pos_y": global_position.y,
		"pos_z": global_position.z,
		"faction" : faction,
		"save_population" : location.location_data.population,
		"state" : state
	}
	if destination:
		dic["destination_path"] = destination.get_path()
	return dic


func _on_load() -> void:
	location.location_data.population = save_population
	if !destination_path:
		return
	await get_tree().process_frame
	destination = get_tree().root.get_node(destination_path)
	var pos = destination.global_position
	navigation_agent.set_target_position(pos)
	state = states.walk


func _on_navigation_agent_3d_navigation_finished() -> void:
	if destination:
		if destination.encounter_scene != null:
			if FactionManager.get_faction_relation(location.location_data.faction, destination.location_data.faction) < 0.0:
				BattleManager.start_battle(destination, location)
				state = states.battle
				location.can_transition = false
			else:
				destination.location_data.change_population(location.location_data.population)
				print(destination.title + " population is now " + str(destination.location_data.population))
				queue_free()
		else:
			queue_free()
	else:
		velocity = Vector3.ZERO
		await get_tree().create_timer(randf_range(1, 3)).timeout
		var pos = global_position + Vector3(randf_range(-3, 3), 0, randf_range(-3, 3))
		pos.y = Globals.get_heightmap_position(pos)
		navigation_agent.set_target_position(pos)


func _on_encounter_started() -> void:
	can_move = false
	velocity = Vector3.ZERO


func _on_encounter_ended() -> void:
	can_move = true


func _on_battle_timer_timeout() -> void:
	if location.location_data.population <= 0:
		die()
	else:
		can_move = true
		state = states.walk


func _on_location_area_entered(area: Area3D) -> void:
	if area is not Location:
		return
	if area.encounter_scene == location.encounter_scene:
		if FactionManager.get_faction_relation(faction, area.location_data.faction) >= 0.0:
			return
		BattleManager.start_battle(area, location)
		state = states.battle
		look_at(area.global_position)
