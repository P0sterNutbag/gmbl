extends Control
class_name PoiDisplay

@export var display_distance: float = 25.5
@onready var text_anchor: Node3D = $"../TextAnchor"
@onready var h_box_container: HBoxContainer = $HBoxContainer


func _ready() -> void:
	hide()
	UiController.ui_opened.connect(_on_ui_opened)


func _process(_delta: float) -> void:
	if Globals.player.camera.camera_type == Globals.player.camera.camera_types.town:
		hide()
		return
	if get_parent().global_position.distance_to(Globals.player.global_position) < display_distance:
		show()
	else:
		hide()
	global_position = get_viewport().get_camera_3d().unproject_position(text_anchor.global_position)


func _on_ui_opened() -> void:
	hide()
