extends CharacterBody3D

enum guns {shotgun, ak47, sniper, pistol}
enum states {walk, chase, patrol}
@export var gun_index: guns
@export var chase_targets: bool
var state = states.walk
var speed := 2
var walk_speed := 2
var run_speed := 3
var path_index := 0
var max_enemies := 6
var min_enemies := 3
var can_move: bool
var original_position: Vector3
var original_rotation: Vector3
var target: Node3D
var destination: Location
var destination_path: NodePath
var faction: FactionManager.factions
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
	set_detection_targets()


func _ready() -> void:
	var gun = guns_dict[gun_index][0].instantiate()
	gun_holder.add_child(gun)
	location.location_data.population = randi_range(min_enemies, max_enemies)
	location.encounter_started.connect(_on_encounter_started)
	location.encounter_ended.connect(_on_encounter_ended)
	SaveController.load.connect(_on_load)
	await get_tree().process_frame
	if location.dialogue_tree != null:
		location.dialogue_tree.npc_style = enemy_model.current_style
		var faction_name = FactionManager.faction_data[faction].name
		if faction_name[-1] == "s":
			faction_name[-1] = ""
		location.dialogue_tree.npc_name = faction_name + " " + location.dialogue_tree.npc_name
	original_position = global_position
	original_rotation = global_rotation


func _process(_delta: float) -> void:
	match (state):
		states.walk:
			speed = walk_speed
			# detect player
			if chase_targets and detection.targets.size() > 0 and can_see_player():
				state = states.chase
			# animate
			if velocity != Vector3.ZERO:
				anim_player.play("Walk")
			else:
				anim_player.play("Idle")
		
		states.chase:
			speed = run_speed
			# chase after player
			if detection.can_see_target(Globals.player) and PlayerStats.state != PlayerStats.states.pause:
				navigation_agent.set_target_position(Globals.player.global_position)
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


func _physics_process(delta: float) -> void:
	# move towards destination
	if navigation_agent.target_position != Vector3.ZERO and can_move:
		follow_path(speed)
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func follow_path(spd: float = walk_speed):
	if navigation_agent.is_navigation_finished():
		return
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	velocity = global_position.direction_to(next_path_position) * spd
	look_at_position(next_path_position)


func look_at_position(pos: Vector3):
	if pos == global_position:
		return
	var target_pos = pos
	target_pos.y = global_position.y
	look_at(target_pos, Vector3.UP)


func set_detection_targets():
	if FactionManager.get_faction_relation(faction, PlayerStats.faction) <= -1.0:
		detection.targets.append(Globals.player)


func can_see_player() -> bool:
	return (detection.can_see_target() and 
	global_position.distance_to(Globals.player.global_position) < 7.5 and
	!UiController.is_canvas_layer_open(Globals.ui))


func die():
	set_collision_layer_value(1, false)
	location.monitoring = false
	location.monitorable = false
	velocity = Vector3.ZERO
	set_process(false)
	set_physics_process(false)
	anim_player.play("Die")
	anim_player.seek(4.4)
	await tree_entered
	UiController.close_interface(Globals.ui.dialogue)
	await get_tree().create_timer(10).timeout
	queue_free()


func save() -> Dictionary:
	var dic = {"pos_x": global_position.x,
		"pos_y": global_position.y,
		"pos_z": global_position.z}
	if destination:
		dic["destination_path"] = destination.get_path()
	return dic
	#return {
		#"pos_x": global_position.x,
		#"pos_y": global_position.y,
		#"pos_z": global_position.z,
		##"target_position": navigation_agent.target_position,
		#"destination_path": destination.get_path(),
	#}


func _on_load() -> void:
	if !destination_path:
		return
	await get_tree().process_frame
	destination = get_tree().root.get_node(destination_path)
	var pos = destination.global_position
	navigation_agent.set_target_position(pos)


func _on_navigation_agent_3d_navigation_finished() -> void:
	if destination:
		if destination.encounter_scene != null:
			if FactionManager.get_faction_relation(location.location_data.faction, destination.location_data.faction) < 0.0:
				destination.start_battle(location.location_data)
			else:
				destination.location_data.change_population(location.location_data.population)
				print(destination.point_of_interest.title + " population is now " + str(destination.location_data.population))
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
