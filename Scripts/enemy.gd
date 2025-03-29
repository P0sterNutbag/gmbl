extends CharacterBody3D

enum states {idle, investigate, attack, search}
var state = states.idle
var speed := 200.0
var time_to_detect_max := 1.5
var time_to_detect: float = time_to_detect_max
var range := 100
var target: Node3D
@onready var firepoint = $EnemyModel/Armature/Skeleton3D/BoneAttachment3D/AssaultRifle_3/FirePoint
@onready var detection = $Detection
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $EnemyModel/AnimationPlayer
signal shoot


func _ready() -> void:
	target = Globals.player
	shoot.connect($ShootComponent._on_shoot)


func _physics_process(delta: float) -> void:
	match state:
		states.idle:
			# switch to investigate
			if detection.can_see_target():
				state = states.investigate
				time_to_detect = time_to_detect_max
			
			# animate
			anim_player.play("Idle")
			
		states.investigate:
			# detect player
			if detection.can_see_target():
				look_at_position(target.global_position)
				var dis_to_target = global_position.distance_to(target.global_position)
				time_to_detect -= (20 / dis_to_target) * delta
				if time_to_detect <= 0:
					state = states.attack
			else:
				state = states.idle
			anim_player.play("Idle")
			
		states.attack:
			# look at player
			look_at_position(target.global_position)
			
			# get into range
			if global_position.distance_to(target.global_position) > range:
				navigation_agent.set_target_position(target.global_position)
				follow_path()
			else:
				velocity = Vector3.ZERO
			
			# switch to search state
			if !detection.can_see_target():
				navigation_agent.set_target_position(target.global_position)
				state = states.search
			
			# animate 
			if velocity == Vector3.ZERO:
				anim_player.play("Shoot")
			else:
				anim_player.play("Walk")
			
		states.search:
			# go to last seen position
			follow_path()
			
			# return to attack
			if detection.can_see_target():
				state = states.attack
				velocity = Vector3.ZERO
			
			# animate
			anim_player.play("Walk")
			
	# Add gravity and move
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func follow_path():
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * speed
	navigation_agent.set_velocity(new_velocity)
	velocity = new_velocity


func look_at_position(pos: Vector3):
	var target_pos = pos
	target_pos.y = global_position.y
	look_at(target_pos, Vector3.UP)


func _on_damaged() -> void:
	if state != states.attack:
		state = states.attack


func _on_death() -> void:
	queue_free()
