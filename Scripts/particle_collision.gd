extends RayCast3D

@export var decal: PackedScene


func _process(_delta: float) -> void:
	#var y = global_position.y
	#var h = get_heightmap_position()
	#if y <= h:
		#create_decal()
		#get_parent().queue_free()
	if is_colliding():
		create_decal()
		get_parent().queue_free()


func create_decal() -> void:
	var inst = decal.instantiate()
	inst.set_deferred("global_position", get_collision_point())
	get_tree().current_scene.add_child(inst)


func get_heightmap_position() -> float:
	var terrain = get_tree().root.get_child(-1).get_node("Terrain")
	var height = terrain.get_data().get_height_at(global_position.x, global_position.z)
	return height


#func _on_body_entered(_body: Node3D) -> void:
	#create_decal()
	#get_parent().queue_free()
