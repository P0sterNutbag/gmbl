extends Node3D

var player_spawn_vector: Vector3
var load_on_enter: bool
var current_encounter: Node3D
var player_place: NodePath
@onready var npc_portrait_model: Node3D = $ShopkeeperPortrait/EnemyModel2
@onready var npc_controller: Node3D = $NpcController


func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	if current_encounter:
		if current_encounter.location_data.population <= 0 and current_encounter.get_parent().has_method("die"):
			current_encounter.get_parent().die()
		var encounter_pos = current_encounter.get_parent().position
		var player_spawn_position = encounter_pos - (player_spawn_vector * 6)
		var player = get_node("Player")
		player.position = player_spawn_position
		player.look_at(current_encounter.position)
		player.rotate_y(deg_to_rad(180))
		player.rotation.x = 0
		player.rotation.y = 0
		#if player_place:
			#var player = get_node("Player")
			#await get_tree().process_frame
			#player.global_transform = current_encounter.get_node(player_place).global_transform


func _ready() -> void:
	Globals.overworld = self
