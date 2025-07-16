extends Control

@export var stat_name: String
@onready var progress_bar: ProgressBar = $ProgressBar
var show_treshold = 0.5


func _process(delta: float) -> void: 
	# make sure stat exists
	if !stat_name in PlayerStats:
		return
	
	# set value
	var stat_value = PlayerStats.get(stat_name)
	var stat_max = PlayerStats.get("max_" + stat_name)
	progress_bar.value = stat_value / stat_max
	
	# make the bar visible or not
	if progress_bar.value < show_treshold:
		visible = true
	else:
		visible = false
