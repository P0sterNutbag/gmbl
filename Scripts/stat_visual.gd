extends Control

@export var stat_name: String
@export var danger_message: String
@export var danger_message2 : String
@export var critical_message: String
@export var show_treshold := 0.9
@export var warning_treshold := 0.5
@export var progress_bar: ProgressBar
var level: int = 0
var tooltip_theme = preload("res://Art/Themes/text_small_outline.tres")


func _process(_delta: float) -> void: 
	# get stat data
	var stat_value = PlayerStats.get(stat_name)
	var stat_max = PlayerStats.get("max_" + stat_name)
	var value = stat_value / stat_max
	var previous_level = level
	# set color
	if value <= 0:
		level = 3
		show()
		modulate.v = 1.0
	elif value < warning_treshold:
		level = 2
		show()
		modulate.v = 0.8
	elif value < show_treshold:
		level = 1
		show()
		modulate.v = 0.65
	else:
		level = 0
		hide()
	# notifications
	if previous_level != level:
		previous_level = level
		if level == 1:
			Globals.survival_ui.create_notification(danger_message)
		elif level == 2:
			Globals.survival_ui.create_notification(danger_message2)
		elif level == 3:
			Globals.survival_ui.create_notification(critical_message)
	# set value
	if !progress_bar:
		return
	progress_bar.value = value


func _make_custom_tooltip(for_text):
	var label = Label.new()
	label.text = for_text
	label.theme = tooltip_theme
	return label


func save() -> Dictionary:
	return {
		"level" : level,
	}
