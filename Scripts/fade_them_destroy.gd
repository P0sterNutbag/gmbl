extends Timer

@onready var decal: Decal = $"../Decal"


func _on_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(decal, "modulate:a", 0, 1)
	tween.tween_callback(get_parent().queue_free)
