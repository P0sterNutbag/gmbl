extends MenuList

@onready var name_label: Label = $HBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/Title
@onready var description_label: Label = $HBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/Description
@onready var reward_label: Label = $HBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/Reward
@onready var confirmation_menu: Control = $ConfirmationMenu
var selected_button: Control
var quest_array


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("drop_item"):
		for item in item_container.get_children():
			if item.has_focus():
				confirmation_menu.show()
				selected_button = item


func delete_quest() -> void:
	PlayerStats.quests.erase(selected_button.resource)
	selected_button.queue_free()


func on_button_focus_entered(button: Control, resource: Resource) -> void:
	super.on_button_focus_entered(button, resource)
	name_label.text = resource.title #resource.type + ": " + resource.title
	description_label.text = resource.description
	if description_label.text == "":
		description_label.hide()
	else:
		description_label.show()
	reward_label.text = "Reward: $" + str(resource.reward.amount)


func _on_yes_pressed() -> void:
	delete_quest()
	confirmation_menu.hide()


func _on_no_pressed() -> void:
	confirmation_menu.hide()


func _on_visibility_changed() -> void:
	confirmation_menu.hide()
	if visible:
		open(PlayerStats.quests)
