extends MenuList

var shop: TownOption
@onready var name_label: Label = $PanelContainer2/MarginContainer/VBoxContainer/Title
@onready var description_label: Label = $PanelContainer2/MarginContainer/VBoxContainer/Description
@onready var reward_label: Label = $PanelContainer2/MarginContainer/VBoxContainer/Reward
@onready var exit_button: Button = $PanelContainer/MarginContainer/VBoxContainer/MenuItem2
@onready var bounty_picture: TextureRect = %BountyPicture
@onready var bounty_viewport: SubViewport = $"../BountyPicture"


func on_button_pressed(button: Control, resource: Resource) -> void:
	super.on_button_pressed(button, resource)
	#if PlayerStats.quests.has(resource):
		#return
	if "start_quest" in resource:
		resource.start_quest()
	PlayerStats.quests.append(resource)
	Globals.survival_ui.compass.set_quest_markers()
	shop.quests.erase(resource)
	button.queue_free()
	#if item_container.get_child_count() == 0:
		#exit_button.grab_focus()
	name_label.text = ""
	description_label.text = ""
	reward_label.text = ""
	bounty_picture.get_parent().hide()


func on_button_focus_entered(button: Control, resource: Resource) -> void:
	super.on_button_focus_entered(button, resource)
	name_label.text = resource.title#resource.type + ": " + resource.title
	description_label.text = resource.description
	if resource is QuestBounty:
		bounty_picture.get_parent().show()
		bounty_picture.texture = resource.target_texture
	else:
		bounty_picture.get_parent().hide()
		bounty_picture.texture = null
	if description_label.text == "":
		description_label.hide()
	else:
		description_label.show()
	reward_label.text = "Reward: $" + str(resource.reward.amount)


func _on_visibility_changed() -> void:
	if visible:
		bounty_picture.get_parent().hide()
