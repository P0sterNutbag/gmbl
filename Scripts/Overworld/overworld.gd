extends Node3D

var player_spawn_vector: Vector3
var player_spawn_position: Vector3
var player_spawn_x: float
var player_spawn_y: float
var player_spawn_z: float
var player_died: bool
var current_encounter: Node3D
@onready var npc_controller: Node3D = $NpcController
@onready var player_start: Node3D = $PlayerStart
@onready var player: CharacterBody3D = $Player


func _enter_tree() -> void:
	await get_tree().process_frame
	process_mode = Node.PROCESS_MODE_INHERIT
	#var player = get_node("Player")
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
	#await get_tree().create_timer(0.1).timeout
	#SaveController.save_data_to_file()


func _ready() -> void:
	Globals.overworld = self
	Globals.player.spring_arm.spring_length = 500
	SaveController.load.connect(_on_load)


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
