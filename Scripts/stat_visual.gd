extends Control

@export var stat_name: String
@export var show_treshold = 0.5
@export var progress_bar: ProgressBar


func _process(_delta: float) -> void: 
	# get stat data
	var stat_value = PlayerStats.get(stat_name)
	var stat_max = PlayerStats.get("max_" + stat_name)
	var value = stat_value / stat_max
	
	# set visibility
	if value < show_treshold:
		visible = true
	else:
		visible = false
		return
	
	# set color
	if value <= 0:
		modulate = Color(1.0, 0.051, 0.271, 1.0)
	else:
		modulate = Color.WHITE
	
	# set value
	if !progress_bar:
		return
	progress_bar.value = value
