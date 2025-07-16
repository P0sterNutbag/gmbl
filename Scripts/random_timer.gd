extends Timer

@export var min_wait_time: float 
@export var max_wait_time: float


func _ready():
	randomize_time()
	start()


func _on_timeout() -> void:
	randomize_time()


func randomize_time() -> void:
	wait_time = randf_range(min_wait_time, max_wait_time)
