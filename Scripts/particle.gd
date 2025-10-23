extends GPUParticles3D

@export var destroy_on_finish: bool = true


func _ready():
	if destroy_on_finish:
		finished.connect(queue_free)
