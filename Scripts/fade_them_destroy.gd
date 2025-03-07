extends Timer

@export var sprite_to_fade: SpriteBase3D


func _on_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(sprite_to_fade, "modulate:a", 0, 1)
	tween.tween_callback(get_parent().queue_free)
