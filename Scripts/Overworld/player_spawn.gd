extends Node3D


func _ready() -> void:
	if !Globals.overworld.current_encounter:
		return
	if Globals.overworld.current_encounter.spawn_player_random:
		var spawn_point = get_child(randi() % get_child_count() - 1)
		get_parent().get_node("Player").global_transform = spawn_point.global_transform
	else:
		var player = get_parent().get_node("Player")
		var placer = get_node(NodePath(Globals.overworld.player_place))
		player.global_transform = placer.global_transform
