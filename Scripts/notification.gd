extends Control

@onready var label: Label = $Label


func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(self, "global_position", global_position + Vector2.UP * 20, 1)
	tween.tween_interval(0.5)
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", global_position + Vector2.UP * 20, 0.5)
	tween.tween_property(self, "modulate:a", 0, 0.5)
	await tween.finished
	queue_free()
