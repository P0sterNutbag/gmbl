extends VBoxContainer

var jobs: Array[Quest]
@onready var label: Label = $Label


func _ready() -> void:
	populate_list()


func populate_list() -> void:
	# make seperate labels for each quest and make them respond to being complete
	label.text = ""
	jobs = PlayerStats.quests
	for job in jobs:
		label.text += "- " + job.title + "\n"
