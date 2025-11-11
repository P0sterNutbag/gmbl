extends Timer

@export var min_wait_time: float 
@export var max_wait_time: float


func _ready():
	randomize_time()
	if !timeout.is_connected(_on_timeout):
		timeout.connect(_on_timeout)


func _on_timeout() -> void:
	randomize_time()


func randomize_time() -> void:
	wait_time = randf_range(min_wait_time, max_wait_time)
