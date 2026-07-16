extends Control

@onready var buildings_list: VBoxContainer = $HBoxContainer2/PanelContainer2/MarginContainer/VBoxContainer
@onready var trading_post: UiButton = $HBoxContainer2/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TradingPost
@onready var barracks: UiButton = $HBoxContainer2/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Barracks
@onready var factory: UiButton = $HBoxContainer2/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/Factory
@onready var buttons = [trading_post, barracks, factory]
const TEXT_OUTLINE = preload("uid://cral201bx2ck")


func activate() -> void:
	var location_data = Globals.overworld.current_encounter.location_data
	for child in buildings_list.get_children():
		if child.get_index() > 1 :
			child.queue_free()
	for string in location_data.current_buildings:
		var inst = Label.new()
		inst.text = string
		inst.theme = TEXT_OUTLINE
		buildings_list.add_child(inst)
	for button in buttons:
		if PlayerStats.money < 100:
			button.disabled = true
		else:
			button.disabled = false
		if location_data.current_buildings.has(button.text):
			button.get_parent().hide()
		else:
			button.get_parent().show()


func add_building(building_name: String, cost: int) -> bool:
	if PlayerStats.money < cost:
		UiController.stop_audio()
		UiController.error_sfx.play()
		if Globals.survival_ui:
			Globals.survival_ui.create_notification("Not enough money")
		return false
	Globals.overworld.current_encounter.location_data.current_buildings.append(building_name)
	PlayerStats.inventory.money -= 100
	Globals.survival_ui.create_notification("You spent $" + str(cost))
	activate()
	return true


func _on_trading_post_pressed() -> void:
	if add_building("Trading Post", 100):
		pass


func _on_barracks_pressed() -> void:
	if add_building("Barracks", 100):
		var locaiton = Globals.overworld.current_encounter
		locaiton.locaiton_data.max_population += 4
		Globals.survival_ui.create_notification(locaiton.title + " max population increased by 4")


func _on_factory_pressed() -> void:
	if add_building("Factory", 100):
		Globals.overworld.current_encounter.location_data.fire_power += 1
		Globals.overworld.current_encounter.location_data.armor_level += 1
		var locaiton = Globals.overworld.current_encounter
		locaiton.locaiton_data.max_population += 4
		Globals.survival_ui.create_notification(locaiton.title + " units equipment level increased by 1")


func _on_exit_menu_pressed() -> void:
	UiController.close_subinterface()


func _on_visibility_changed() -> void:
	if visible:
		activate()
