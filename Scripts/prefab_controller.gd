@tool
extends Node3D
@export_category("Spawning")
@export var spawn_npcs: bool
@export var spawn_loot: bool
@export var spawn_traps: bool
@export_category("Positioning")
#@export var spin := false : set = rotate_objects
@onready var npc_spawns: Node3D = $NpcSpawns
@onready var loot_spawns: Node3D = $LootSpawns
@onready var trap_spawns: Node3D = $TrapSpawns


#func _enter_tree() -> void:
	#if npc_spawns:
		#if !spawn_npcs: npc_spawns.process_mode = Node.PROCESS_MODE_DISABLED
		#else: npc_spawns.process_mode = Node.PROCESS_MODE_INHERIT
	#if loot_spawns:
		#if !spawn_loot: loot_spawns.process_mode = Node.PROCESS_MODE_DISABLED
		#else: loot_spawns.process_mode = Node.PROCESS_MODE_INHERIT
	#if trap_spawns:
		#if !spawn_traps: trap_spawns.process_mode = Node.PROCESS_MODE_DISABLED
		#else: trap_spawns.process_mode = Node.PROCESS_MODE_INHERIT


func rotate_objects(_value) -> void:
	rotation.y = randf_range(0.0, deg_to_rad(360))
