extends Label

@export var input_action: String
@onready var timer: Timer = $Timer


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(input_action):
		timer.start()
	if timer.time_left > 0:
		modulate.a = timer.time_left / timer.wait_time


func _on_timer_timeout() -> void:
	queue_free()
