extends MenuList

@onready var name_label: Label = $PanelContainer2/MarginContainer/VBoxContainer/Title
@onready var description_label: Label = $PanelContainer2/MarginContainer/VBoxContainer/Description
@onready var reward_label: Label = $PanelContainer2/MarginContainer/VBoxContainer/Reward
var quest_array


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("drop_item"):
		for item in item_container.get_children():
			if item.has_focus():
				PlayerStats.quests.erase(item.resource)
				item.queue_free()


func on_button_focus_entered(button: Control, resource: Resource) -> void:
	super.on_button_focus_entered(button, resource)
	name_label.text = resource.title #resource.type + ": " + resource.title
	description_label.text = resource.description
	if description_label.text == "":
		description_label.hide()
	else:
		description_label.show()
	reward_label.text = "Reward: $" + str(resource.reward.amount)
