extends Node3D

@export var possible_spawns: Array[SpawnChance]
@export var spawn_chance: float = 0
@export var spawn_amount: int = 1
@export var location_data_variable: String
var used_spawns: Array[int]


func _ready() -> void:
	await get_tree().process_frame
	if "location_data" in get_tree().current_scene:
		spawn_chance = get_tree().current_scene.location_data.get(location_data_variable)
	if randf() <= spawn_amount:
		spawn_loot(spawn_amount)


func spawn_loot(amount: int = 1):
	for i in amount:
		var spawns = get_children()
		var index = randi_range(0, spawns.size() - 1)
		while used_spawns.has(index):
			index = randi_range(0, spawns.size() - 1)
		var loot_to_spawn = possible_spawns[Globals.get_weighted_index(possible_spawns)].object_to_spawn
		var inst = loot_to_spawn.instantiate()
		get_tree().current_scene.add_child.call_deferred(inst)
		inst.global_transform = spawns[index].global_transform
		used_spawns.append(index)
