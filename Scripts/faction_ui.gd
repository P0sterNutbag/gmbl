extends Control

@onready var faction_camera: Camera3D = $CameraAnchor/SpringArm3D/Camera
@onready var camera_anchor: Node3D = $CameraAnchor
@onready var squad_box: PanelContainer = $VBoxContainer/PanelContainer
@onready var reserve_box: PanelContainer = $VBoxContainer/PanelContainer2
var location_index: int
var camera_target: Node3D


func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	camera_target = PlayerStats.owned_locations[location_index]


func _process(delta: float) -> void:
	if camera_target and camera_target.is_inside_tree():
		camera_anchor.global_position = lerp(camera_anchor.global_position, camera_target.global_position, delta * 5)
	if !visible:
		return
	if Input.is_action_just_pressed("ui_right"):
		set_location(1)
	if Input.is_action_just_pressed("ui_left"):
		set_location(-1)
	camera_anchor.rotation_degrees.y += delta * 2


func set_location(index_change: int = 1) -> void:
	location_index = wrapi(location_index + index_change, 0, PlayerStats.owned_locations.size())
	camera_target = PlayerStats.owned_locations[location_index]
	if camera_target is Location:
		squad_box.set_location(camera_target.location_data)
	elif camera_target == Globals.player:
		squad_box.set_location(PlayerStats.squad_location)


func activate() -> void:
	faction_camera.current = true
	camera_target = PlayerStats.owned_locations[location_index]
	set_location(0)
	reserve_box.set_location(PlayerStats.reserve_location)


func deactivate() -> void:
	Globals.player.camera.current = true


func _on_visibility_changed() -> void:
	if visible:
		activate()
	else:
		deactivate()


func _on_button_pressed() -> void:
	set_location(-1)


func _on_button_2_pressed() -> void:
	set_location()
