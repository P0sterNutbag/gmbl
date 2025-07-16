extends MenuList

@onready var name_label: Label = $PanelContainer2/MarginContainer/VBoxContainer/Label
@onready var location_label: Label = $PanelContainer2/MarginContainer/VBoxContainer/Label2
@onready var reward_label: Label = $PanelContainer2/MarginContainer/VBoxContainer/Label3


func on_button_focus_entered(button: Control, resource: Resource) -> void:
	super.on_button_focus_entered(button, resource)
	name_label.text = resource.title
	location_label.text = "Last seen in" + resource.location
	reward_label.text = "$" + str(resource.reward.amount)
