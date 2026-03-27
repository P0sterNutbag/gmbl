extends MeshInstance3D

@export var bob_frequency := 1.0
@export var bob_amplitude := 1.0
var time = 0


func _process(delta: float) -> void:
	if !visible:
		time = 0
		return
	time += delta
	var bob = cos(time * bob_frequency) * bob_amplitude
	position.y += bob * delta
