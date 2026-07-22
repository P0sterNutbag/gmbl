extends Node3D

@export var possible_scenes: Array[SpawnChance]
@export var spawn_amount_min: int = 0
@export var spawn_amount_max: int = 10
var used_spawns: Array[int]


func _ready() -> void:
	var spawn_amount = clamp(randi_range(spawn_amount_min, spawn_amount_max), 0, get_child_count())
	for i in spawn_amount:
		spawn()


func spawn():
	var spawns = get_children()
	var index = randi_range(0, spawns.size() - 1)
	if used_spawns.size() < spawns.size():
		while used_spawns.has(index):
			index = randi_range(0, spawns.size() - 1)
	var scene = possible_scenes[Globals.get_weighted_index(possible_scenes)].object_to_spawn
	var inst = scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(inst)
	inst.set_deferred("global_position", spawns[index].global_position)
	used_spawns.append(index)
