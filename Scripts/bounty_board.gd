extends MenuList

var shop: Shop
@onready var name_label: Label = $PanelContainer2/MarginContainer/VBoxContainer/Label
@onready var location_label: Label = $PanelContainer2/MarginContainer/VBoxContainer/Label3
@onready var reward_label: Label = $PanelContainer2/MarginContainer/VBoxContainer/Label2


func on_button_pressed(button: Control, resource: Resource) -> void:
	super.on_button_pressed(button, resource)
	if PlayerStats.quests.has(resource):
		return
	PlayerStats.quests.append(resource)
	shop.quests.erase(resource)
	button.queue_free()


func on_button_focus_entered(button: Control, resource: Resource) -> void:
	super.on_button_focus_entered(button, resource)
	name_label.text = resource.title
	location_label.text = "Last seen in " + resource.location
	reward_label.text = "$" + str(resource.reward.amount)


#func _on_menu_item_pressed() -> void:
	#open.call_deferred(shop.quests)
#
#
#func _on_menu_item_2_pressed() -> void:
	#open.call_deferred(PlayerStats.quests)
