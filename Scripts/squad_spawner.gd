extends Node3D

@export var enemies_to_spawn: Array[SpawnChance]
@export var borders: Array[Area3D]
var enemy_amount: int = 3
var spawn_radius: float = 8
var enemies: Array
@onready var timer: Timer = $Timer


func _ready() -> void:
	for i in enemy_amount:
		var enemy_index = Globals.get_weighted_index(enemies_to_spawn)
		var inst = enemies_to_spawn[enemy_index].object_to_spawn.instantiate()
		get_tree().current_scene.add_child.call_deferred(inst)
		inst.process_mode = Node.PROCESS_MODE_DISABLED
		enemies.append(inst)


func spawn_squad() -> void:
	var border_index = randi_range(0, borders.size() - 1)
	var border = borders[border_index]
	var spawn_point = border.global_position
	var border_index2 = randi_range(0, borders.size() - 1)
	while border_index2 == border_index:
		border_index2 = randi_range(0, borders.size() - 1)
	var dest = borders[border_index2].global_position
	# spawn enemies
	for inst in enemies:
		# get random enemy and spawn it
		inst.process_mode = Node.PROCESS_MODE_INHERIT
		#var enemy_index = Globals.get_weighted_index(enemies_to_spawn)
		#var inst = enemies_to_spawn[enemy_index].object_to_spawn.instantiate()
		#get_tree().current_scene.add_child.call_deferred(inst)
		# position enemy at spawn point
		var offset = Vector3(randf_range(-spawn_radius, spawn_radius), 0, randf_range(-spawn_radius, spawn_radius))
		inst.set_deferred("global_position", spawn_point + offset)
		inst.destination = dest + spawn_point
		inst.free_on_destination = false
		inst.look_at_position(inst.destination)
		#enemies.append(inst)
	#await get_tree().create_timer(1).timeout
	#for enemy in enemies:
		#enemy.change_state(enemy.states.walk)


func _on_timer_timeout() -> void:
	spawn_squad()
