extends PanelContainer

@onready var label: Label = $MarginContainer/Label

var text: String: 
	set(value):
		text = value
		label.text = text
