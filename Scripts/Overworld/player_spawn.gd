extends Node3D

@onready var player: Player = $"../Player"
@onready var player_spawn: Node3D = $PlayerSpawn
@onready var cover_spawn: Node3D = $CoverSpawn


func _ready() -> void:
	if Globals.overworld:
		var dis = player_spawn.position.z
		player_spawn.position = -Globals.overworld.player_spawn_vector * dis
		dis = cover_spawn.position.z
		cover_spawn.position = -Globals.overworld.player_spawn_vector * dis
	#print(player_spawn.global_position)
	player.global_position = player_spawn.global_position
	player.face_center()
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
