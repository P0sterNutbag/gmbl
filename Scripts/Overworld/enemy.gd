extends CharacterBody3D

var walk_speed := 2
@onready var detection: Node3D = $Detection
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $EnemyModel/PersonAnimated/AnimationPlayer


func _ready() -> void:
	detection.targets.append(Globals.player)


func _process(delta: float) -> void:
	if detection.get_visible_target():
		navigation_agent.set_target_position(Globals.player.global_position)
	follow_path()
	
	# animate
	if velocity != Vector3.ZERO:
		anim_player.play("Run")
	else:
		anim_player.play("Idle")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func follow_path(speed: float = walk_speed):
	if navigation_agent.is_navigation_finished():
		return
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	next_path_position.y = global_position.y
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * speed
	navigation_agent.set_velocity(velocity)
	velocity = new_velocity
	look_at_position(next_path_position)


func look_at_position(pos: Vector3):
	var target_pos = pos
	target_pos.y = global_position.y
	look_at(target_pos, Vector3.UP)


func _on_navigation_agent_3d_navigation_finished() -> void:
	velocity = Vector3.ZERO
