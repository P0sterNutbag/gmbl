extends Node3D

@export var spawn_relative: bool = true
@export var spawn_clamp: Vector2
@onready var player: Player = $"../Player"
@onready var player_spawn: Node3D = $PlayerSpawn
@onready var cover_spawn: Node3D = $CoverSpawn


func _ready() -> void:
	if Globals.overworld and spawn_relative:
		var dis = player_spawn.position.z
		player_spawn.position = -Globals.overworld.player_spawn_vector * dis
		player_spawn.position.x = clamp(player_spawn.position.x, spawn_clamp.x, 257 - spawn_clamp.x)
		player_spawn.position.z = clamp(player_spawn.position.z, spawn_clamp.y, 257 - spawn_clamp.y)
		player_spawn.position_on_heightmap()
		dis = cover_spawn.position.z
		cover_spawn.position = -Globals.overworld.player_spawn_vector * dis
	#print(player_spawn.global_position)
	player.global_position = player_spawn.global_position
	player.face_center(global_position)
	#remove_child(player)
	#get_parent().add_child(player)


#func _ready() -> void:
	#if Globals.overworld == null:
		#return
	#if !Globals.overworld.current_encounter:
		#return
	#if Globals.overworld.current_encounter.spawn_player_random:
		#var spawn_point = get_child(randi() % get_child_count() - 1)
		#get_parent().get_node("Player").global_transform = spawn_point.global_transform
	#else:
		#var player = get_parent().get_node("Player")
		#var placer = get_node(NodePath(Globals.overworld.player_place))
		#player.global_transform = placer.global_transform
