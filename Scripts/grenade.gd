extends RigidBody3D

var explosion = preload("res://Scenes/Bullets/explosion.tscn")


func explode() -> void:
	var inst = explosion.instantiate()
	inst.global_position = global_position
	get_tree().current_scene.add_child(inst)
	queue_free()


func _on_timer_timeout() -> void:
	explode()


func _on_body_entered(body: Node) -> void:
	if body is Enemy:
		explode()
