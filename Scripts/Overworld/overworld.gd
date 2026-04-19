extends Node3D

var player_spawn_vector: Vector3
var player_spawn_position: Vector3
var player_spawn_x: float
var player_spawn_y: float
var player_spawn_z: float
var player_died: bool
var current_encounter: Node3D
var poi_populations = [4, 6, 8, 10]
var poi_factions = [0, 4, 4, 4]
@onready var npc_controller: Node3D = $NpcController
@onready var player_start: Node3D = $PlayerStart
@onready var player: CharacterBody3D = $Player
@onready var rock_canyon: Location = $RockCanyon
@onready var sand_dunes: Location = $SandDunes
@onready var generic_location: Location = $GenericLocation
@onready var generic_location_2: Location = $GenericLocation2
@onready var pois = [rock_canyon, sand_dunes, generic_location, generic_location_2]


func _enter_tree() -> void:
	await get_tree().process_frame
	process_mode = Node.PROCESS_MODE_INHERIT
	if player_died:
		player.transform = player_start.transform
		player.camera_anchor.rotation = Vector3.ZERO
		player_died = false
	elif current_encounter:
		if current_encounter.location_data.population <= 0 and current_encounter.get_parent().has_method("die"):
			current_encounter.get_parent().die()
		var encounter_pos = current_encounter.global_position
		player_spawn_position = encounter_pos + (player_spawn_vector * 4).rotated(Vector3.UP, current_encounter.rotation.y)
		player_spawn_position.y = Globals.get_heightmap_position(player_spawn_position)
		player.global_position = player_spawn_position
		player.look_at(current_encounter.global_position)
		player.rotate_y(deg_to_rad(180))
		player.rotation.x = 0
		player.rotation.y = 0


func _ready() -> void:
	Globals.overworld = self
	Globals.player.spring_arm.spring_length = 500
	SaveController.load.connect(_on_load)
	for poi in pois:
		var data = poi.location_data
		var index = randi() % poi_populations.size()
		data.population = poi_populations[index]
		data.max_population = poi_populations[index]
		poi_populations.remove_at(index)
		index = randi() % poi_factions.size()
		data.faction = poi_factions[index]
		poi_factions.remove_at(index)


func save() -> Dictionary:
	if current_encounter == null:
		player_spawn_position = Globals.player.global_position
	else:
		player_spawn_position = current_encounter.global_position + (Globals.player.position - current_encounter.global_position).normalized() * 4
	return {
		"player_spawn_x": player_spawn_position.x,
		"player_spawn_y": player_spawn_position.y,
		"player_spawn_z": player_spawn_position.z,
	}


func _on_load() -> void:
	player_spawn_position = Vector3(player_spawn_x, player_spawn_y, player_spawn_z)
	Globals.player.global_position = player_spawn_position
