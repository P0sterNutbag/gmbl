extends Node3D
class_name PointOfInterest

@export var show_faction: bool = true
@export var show_population: bool = true
@onready var title_label: Label = %Title
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var location_card: Control = $CanvasLayer/CardOffset
@onready var faction_label: Label = %Faction
@onready var population_label: Label = %Population
@onready var text_anchor: Node3D = $TextAnchor
@onready var status_holder: HBoxContainer = $CanvasLayer/CardOffset/VBoxContainer/HBoxContainer3
@onready var status_label: Label = $CanvasLayer/CardOffset/VBoxContainer/HBoxContainer3/Status


func _ready() -> void:
	#title_label.text = title
	#if title_label.text == "":
		#title_label.hide()
	canvas_layer.hide()


func _process(_delta: float) -> void:
	if !canvas_layer.visible:
		return
	location_card.global_position = get_viewport().get_camera_3d().unproject_position(text_anchor.global_position)
	var location_data = get_parent().location_data
	title_label.text = get_parent().title
	if show_faction:
		var faction = location_data.faction
		var faction_name = FactionManager.faction_data[faction].name
		faction_label.text = faction_name
	else:
		faction_label.get_parent().hide()
	if show_population:
		if location_data.population == 0:
			population_label.text = "0"
		else:
			population_label.text = str(location_data.min_population) + "-" + str(location_data.max_population)
	else:
		population_label.get_parent().hide()



func _on_area_3d_body_entered(_body: Node3D) -> void:
	canvas_layer.show()


func _on_area_3d_body_exited(_body: Node3D) -> void:
	canvas_layer.hide()


func _exit_tree() -> void:
	canvas_layer.hide()
