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
var has_player: bool
var has_mouse: bool


func _ready() -> void:
	canvas_layer.hide()
	UiController.ui_opened.connect(_on_ui_opened)
	title_label.text = get_parent().title


func _process(_delta: float) -> void:
	if Globals.player.camera.camera_type == Globals.player.camera.camera_types.town:
		canvas_layer.hide()
		return
	if global_position.distance_to(Globals.player.global_position) < 25.5:
		canvas_layer.show()
	else:
		canvas_layer.hide()
	location_card.global_position = get_viewport().get_camera_3d().unproject_position(text_anchor.global_position)
	var location_data = get_parent().location_data
	if show_faction:
		var faction_name = FactionManager.faction_data[int(location_data.faction)].name
		faction_label.text = faction_name
	else:
		faction_label.text = "???"
	if show_population:
		if location_data.population == 0:
			population_label.text = "0"
		else:
			population_label.text = str(location_data.population)
	else:
		population_label.text = "???"


func _on_ui_opened() -> void:
	canvas_layer.hide()
