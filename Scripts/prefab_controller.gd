@tool
extends Node3D
@export_category("Spawning")
@export var spawn_npcs: bool
@export var spawn_loot: bool
@export var spawn_traps: bool
@export_category("Position Children")
@export var terrain: Node3D
@export var nodes_to_exclude: Array[Node3D]
@export var buffer: float
@export var snap_to_terrain := false : set = position_on_terrain
#@export_tool_button("snap", "Area2D") var action = position_on_terrain
@onready var npc_spawns: Node3D = $NpcSpawns
@onready var loot_spawns: Node3D = $LootSpawns
@onready var trap_spawns: Node3D = $TrapSpawns


#func _enter_tree() -> void:
	#if !spawn_npcs:
		#npc_spawns.queue_free()
	#if !spawn_loot:
		#loot_spawns.queue_free()
	#if !spawn_traps:
		#trap_spawns.queue_free()


func position_on_terrain(_value) -> void:
	if !terrain:
		return
	for child in get_children():
		if nodes_to_exclude.has(child):
			continue
		var height = terrain.get_data().get_height_at(child.global_position.x, child.global_position.z)
		child.global_position.y = height + buffer
