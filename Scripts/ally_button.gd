extends Control

@onready var name_label: Label = $Label
@onready var rank_label: Label = $Label2


var title: String:
	set(value):
		title = value
		name_label.text = title
var rank: String:
	set(value):
		rank = value
		rank_label.text = "Rank: " + rank
