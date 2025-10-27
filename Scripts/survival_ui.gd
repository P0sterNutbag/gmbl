extends CanvasLayer

var compass_object: Node3D
@onready var compass: ColorRect = $TopCenter/Compass/ColorRect


func _enter_tree() -> void:
	#Globals.ui = self
	await get_tree().process_frame
	if get_tree().current_scene.name == "Overworld":
		compass_object = Globals.player.get_node_or_null("CameraAnchor")
	else:
		compass_object = Globals.player


func _process(_delta: float) -> void:
	# compass movement
	var cam_rot = rad_to_deg(compass_object.rotation.y)
	compass.position.x = compass.size.x * ((cam_rot / 360.0) + 0.5) - compass.size.x - 70
	# open pause menu
	#if Input.is_action_just_pressed("ui_cancel"):
		#if PlayerStats.state != PlayerStats.states.pause:
			#Globals.pause_game()
