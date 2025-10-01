extends Node3D
class_name PointOfInterest

@export_multiline var title: String
@export_multiline var description: String
@onready var title_label: Label = %Title
@onready var description_label: Label = %Description
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var location_card: Control = $CanvasLayer/CardOffset


func _ready() -> void:
	title_label.text = title
	if title_label.text == "":
		title_label.hide()
	description_label.text = description
	if description_label.text == "":
		description_label.hide()
	canvas_layer.hide()


func _process(_delta: float) -> void:
	if !canvas_layer.visible:
		return
	location_card.global_position = get_viewport().get_camera_3d().unproject_position(global_transform.origin)


func _on_area_3d_body_entered(_body: Node3D) -> void:
	canvas_layer.show()


func _on_area_3d_body_exited(_body: Node3D) -> void:
	canvas_layer.hide()


func _exit_tree() -> void:
	canvas_layer.hide()
