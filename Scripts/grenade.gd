extends RigidBody3D

var explosion = preload("res://Scenes/Bullets/explosion.tscn")


func _exit_tree() -> void:
    Globals.create_instance(explosion, global_position)


func _on_timer_timeout() -> void:
    queue_free()


func _on_body_entered(body: Node) -> void:
    if body is Enemy:
        queue_free()
