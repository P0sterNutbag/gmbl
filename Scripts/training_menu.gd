extends MenuList

@onready var skills: VBoxContainer = %Skills
@onready var training_items: VBoxContainer = %TrainingItems
var skill_to_train: String
signal skill_changed(skill_name: String)


func _ready() -> void:
	skill_changed.connect(PlayerStats._on_skill_changed)


func open_items(skill_name: String) -> void:
	skill_to_train = skill_name
	skills.hide()
	training_items.show()
	var items = PlayerStats.inventory.items.filter(func(a): return "skill" in a and a.skill == skill_name)
	open(items)


func on_button_pressed(button: Control, resource: Resource) -> void:
	super.on_button_pressed(button, resource)
	PlayerStats.inventory.remove_item(resource)
	skill_to_train = resource.skill
	PlayerStats.skills.set(skill_to_train, PlayerStats.skills.get(skill_to_train) + resource.effectiveness)
	skill_changed.emit(skill_to_train)
	PlayerStats.go_to_sleep(0.5)
	await PlayerStats.sleep_finished
	Globals.survival_ui.create_notification(skill_to_train.to_upper() + " increased by 1")
	UiController.open_interface(Globals.ui.town)



func _on_toughness_pressed() -> void:
	open_items("toughness")


func _on_strength_pressed() -> void:
	open_items("strength")


func _on_speed_pressed() -> void:
	open_items("speed")


func _on_handguns_pressed() -> void:
	open_items("handguns")


func _on_long_guns_pressed() -> void:
	open_items("long guns")


func _on_exit_button_pressed() -> void:
	if training_items.visible:
		training_items.hide()
		skills.show()
	else:
		await get_tree().process_frame
		UiController.open_interface(Globals.ui.town)


func _on_visibility_changed() -> void:
	if visible:
		skills.show()
		training_items.hide()
