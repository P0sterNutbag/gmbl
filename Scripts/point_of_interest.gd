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
var has_player: bool
var has_mouse: bool


func _ready() -> void:
	#title_label.text = title
	#if title_label.text == "":
		#title_label.hide()
	canvas_layer.hide()


func _process(_delta: float) -> void:
	if Globals.player.camera_type == Globals.player.camera_types.town:
		canvas_layer.hide()
		return
	# mouse hover
	var viewport = get_viewport()
	var pos = Globals.player.camera.unproject_position(global_position)
	var had_mouse = has_mouse
	has_mouse = viewport.get_mouse_position().distance_to(pos) < 64 and global_position.distance_to(Globals.player.camera.global_position) <= 85
	if !had_mouse and has_mouse:
		canvas_layer.show()
	elif had_mouse and !has_mouse and !has_player:
		canvas_layer.hide()
	# set data on card
	if !canvas_layer.visible:
		return
	location_card.global_position = get_viewport().get_camera_3d().unproject_position(text_anchor.global_position)
	var location_data = get_parent().location_data
	title_label.text = get_parent().title
	if show_faction:
		#faction_label.get_parent().show()
		var faction_name = FactionManager.faction_data[int(location_data.faction)].name
		faction_label.text = faction_name
	else:
		faction_label.text = "???"
		#faction_label.get_parent().hide()
	if show_population:
		#population_label.get_parent().show()
		if location_data.population == 0:
			population_label.text = "0"
		else:
			population_label.text = str(location_data.population)#str(location_data.min_population) + "-" + str(location_data.max_population)
	else:
		population_label.text = "???"
		#population_label.get_parent().hide()



func _on_area_3d_body_entered(_body: Node3D) -> void:
	canvas_layer.show()
	has_player = true


func _on_area_3d_body_exited(_body: Node3D) -> void:
	canvas_layer.hide()
	has_player = false


#func _exit_tree() -> void:
	#canvas_layer.hide()


func _on_canvas_layer_visibility_changed() -> void:
	if canvas_layer.visible:
		if owner.get_parent() is CharacterBody3D:
			var location = owner.get_parent().location
			var battle = BattleManager.get_battle(location)
			if battle:
				for i in battle.all_locations:
					var poi = i.point_of_interest
					if poi != self:
						poi.canvas_layer.hide()


func save() -> Dictionary:
	return {
		"show_faction" : show_faction,
		"show_population" : show_population,
	}
