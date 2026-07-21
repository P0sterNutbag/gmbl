extends Control

@onready var buildings_list: VBoxContainer = %VBoxContainer
@onready var money_label: Label = %Label2
@onready var tooltip: Control = $ItemTooltip
@onready var tooltip_label: Label = $ItemTooltip/PanelContainer/MarginContainer/VBoxContainer/Label
@onready var availabel_buildings: VBoxContainer = $HBoxContainer2/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer
const TEXT_OUTLINE = preload("uid://cral201bx2ck")
const MENU_ITEM = preload("uid://ca8traqagv62t")


func activate() -> void:
	var location_data = Globals.overworld.current_encounter.location_data
	for child in availabel_buildings.get_children():
		child.queue_free()
	for child in buildings_list.get_children():
		child.queue_free()
	for building in location_data.available_buildings:
		var inst = MENU_ITEM.instantiate()
		availabel_buildings.add_child(inst)
		inst.text = building.title
		inst.price = building.price
		inst.pressed.connect(_on_building_pressed.bind(building))
		inst.mouse_entered.connect(_on_button_mouse_entered.bind(building))
		inst.mouse_exited.connect(_on_button_mouse_exited)
	for building in location_data.current_buildings:
		var inst = Label.new()
		inst.text = building.title
		inst.theme = TEXT_OUTLINE
		buildings_list.add_child(inst)
	money_label.text = "$" + str(PlayerStats.inventory.money)


func _on_building_pressed(building: Building) -> void:
	if PlayerStats.money < building.price:
		UiController.stop_audio()
		UiController.error_sfx.play()
		return
	PlayerStats.inventory.money -= building.price
	var location_data: LocationData = Globals.overworld.current_encounter.location_data
	for effect in building.effects:
		effect.change_value(location_data)
	location_data.available_buildings.erase(building)
	location_data.current_buildings.append(building)
	activate()


func _on_button_mouse_entered(building: Building) -> void:
	tooltip.show()
	tooltip.description.text = building.description


func _on_button_mouse_exited() -> void:
	tooltip.hide()
	


func _on_exit_menu_pressed() -> void:
	UiController.close_subinterface()


func _on_visibility_changed() -> void:
	if visible:
		activate()
