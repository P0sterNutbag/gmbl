extends MenuList

var shop: Shop
@onready var name_label: Label = $PanelContainer2/MarginContainer/VBoxContainer/Title
@onready var description_label: Label = $PanelContainer2/MarginContainer/VBoxContainer/Description
@onready var reward_label: Label = $PanelContainer2/MarginContainer/VBoxContainer/Reward
@onready var exit_button: Button = $PanelContainer/MarginContainer/VBoxContainer/MenuItem2


func on_button_pressed(button: Control, resource: Resource) -> void:
	super.on_button_pressed(button, resource)
	#if PlayerStats.quests.has(resource):
		#return
	PlayerStats.quests.append(resource)
	shop.quests.erase(resource)
	button.queue_free()
	if item_container.get_child_count() == 0:
		exit_button.grab_focus()


func on_button_focus_entered(button: Control, resource: Resource) -> void:
	super.on_button_focus_entered(button, resource)
	name_label.text = resource.type + ": " + resource.title
	description_label.text = resource.description
	reward_label.text = "Reward: $" + str(resource.reward.amount)


#func _on_menu_item_pressed() -> void:
	#open.call_deferred(shop.quests)
#
#
#func _on_menu_item_2_pressed() -> void:
	#open.call_deferred(PlayerStats.quests)
