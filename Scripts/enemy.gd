extends CharacterBody3D

enum states {idle, investigate, attack}
var state = states.idle
var speed: float = 5.0
var time_to_detect_max: float = 1.5
var time_to_detect: float = time_to_detect_max
var target: Node3D
@onready var firepoint = $MeshInstance3D2/FirePoint
@onready var detection = $Detection
@onready var shoot_timer = $ShootTimer
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
signal shoot


func _ready() -> void:
	target = Globals.player
	shoot.connect($ShootComponent._on_shoot)


func _physics_process(delta: float) -> void:
	match state:
		states.idle:
			if detection.can_see_target():
				state = states.investigate
				time_to_detect = time_to_detect_max
		states.investigate:
			if detection.can_see_target():
				look_at(target.global_position, Vector3.UP)
				var dis_to_target = global_position.distance_to(target.global_position)
				time_to_detect -= (20 / dis_to_target) * delta
				if time_to_detect <= 0:
					state = states.attack
					shoot_timer.start()
			else:
				state = states.idle
		states.attack:
			# chase player
			look_at(target.global_position, Vector3.UP)
			navigation_agent.set_target_position(target.global_position)
			var current_agent_position: Vector3 = global_position
			var next_path_position: Vector3 = navigation_agent.get_next_path_position()
			velocity = current_agent_position.direction_to(next_path_position) * speed
	# Add gravity and move
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func _on_timer_timeout() -> void:
	$MeshInstance3D2.look_at(target.global_position)
	shoot.emit()


func _on_death() -> void:
	queue_free()
