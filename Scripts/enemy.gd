extends CharacterBody3D

@export var target: Node3D
const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# chase player
	look_at(target.global_position, Vector3.UP)
	velocity = Vector3.FORWARD * SPEED
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	move_and_slide()
