extends Control

@export var title_value: String = "???":
	set(value):
		title_value = value
		title.text = value
@export var faction_value: String = "???":
	set(value):
		faction_value = value
		faction_text.text = value
@export var difficulty_value: String = "???":
	set(value):
		difficulty_value = value
		difficulty_text.text = value
@export var resources_value: String = "???":
	set(value):
		resources_value = value
		resources_text.text = value
@onready var title: Label = %Title
@onready var faction_text: Label = %FactionValue
@onready var difficulty_text: Label = %DifficultyValue
@onready var resources_text: Label = %ResourcesValue
var target: Node3D


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	global_position = get_viewport().get_camera_3d().unproject_position(target.global_transform.origin)
