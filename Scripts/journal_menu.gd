extends MenuList

@onready var name_label: Label = $PanelContainer2/MarginContainer/VBoxContainer/Title
@onready var description_label: Label = $PanelContainer2/MarginContainer/VBoxContainer/Description
@onready var reward_label: Label = $PanelContainer2/MarginContainer/VBoxContainer/Reward
@onready var exit_button: Button = $PanelContainer/MarginContainer/VBoxContainer/MenuItem
var quest_array


func open(array: Array):
	super.open(array)
	if array.size() == 0:
		exit_button.grab_focus()


func on_button_focus_entered(button: Control, resource: Resource) -> void:
	super.on_button_focus_entered(button, resource)
	name_label.text = resource.title #resource.type + ": " + resource.title
	description_label.text = resource.description
	if description_label.text == "":
		description_label.hide()
	else:
		description_label.show()
	reward_label.text = "Reward: $" + str(resource.reward.amount)
