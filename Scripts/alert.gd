extends Control

var text: String:
	set(value):
		text = value
		$Label.text = text


func _ready() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 64, 1.5)
	tween.tween_interval(1)
	tween.set_parallel(false)
	tween.tween_property(self, "modulate:a", 0, 0.5)
