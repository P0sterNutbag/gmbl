extends VBoxContainer

@onready var name_label: Label = $HBoxContaier/PanelContainer/MarginContainer/VBoxContainer/Label
@onready var resource_label: Label = $HBoxContaier/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer2/Label
@onready var resource_bar: ProgressBar = $HBoxContaier/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Control/ProgressBar
@onready var resource_bar_back: ProgressBar = $HBoxContaier/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Control/ProgressBar2
@onready var equipment_label: Label = $HBoxContaier/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer3/Label
@onready var equipment_bar: ProgressBar = $HBoxContaier/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Control/ProgressBar
@onready var equipment_bar_back: ProgressBar = $HBoxContaier/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Control/ProgressBar2
@onready var poi_menu: PanelContainer = $"../PoiMenu"
@onready var inventory: InventoryUI = $HBoxContaier/Inventory
@onready var inventory_2: InventoryUI = $HBoxContaier/Inventory2
var location: Location


func activate(_location: Location) -> void:
	location = _location
	inventory.source_inventory = PlayerStats.inventory
	inventory.target_inventory = Inventory.new()
	inventory.show()
	var location_data = location.location_data
	name_label.text = location.title
	name_label.text = location.title
	resource_label.text = str(int(location_data.resources))
	equipment_label.text = "lvl " + str(location_data.firepower + location_data.armor_level)


func increase_resources(value: int) -> void:
	var current_value = resource_bar.value
	if current_value + value > 100:
		location.location_data.resources += 1
		resource_label.text = str(int(location.location_data.resources))
	resource_bar.value = wrapi(current_value + value, 0, 100)


func increase_equipment(value: int) -> void:
	var current_value = equipment_bar.value
	if current_value + value > 100:
		location.location_data.firepower += 1
		equipment_label.text = "lvl " +  str(location.location_data.firepower + location.location_data.armor_level)
	equipment_bar.value = wrapi(current_value + value, 0, 100)


func _on_inventory_item_transferred(item: Item) -> void:
	if item.category == Item.categories.ammo or item.category == Item.categories.guns or item.category == Item.categories.armor:
		increase_equipment(item.price)
	else:
		increase_resources(item.price)


func _on_exit_menu_pressed() -> void:
	UiController.open_interface(poi_menu)


func _on_inventory_item_focus_entered(item: Item) -> void:
	if item.category == Item.categories.ammo or item.category == Item.categories.guns or item.category == Item.categories.armor:
		equipment_bar_back.value = equipment_bar.value + item.price
	else:
		resource_bar_back.value = resource_bar.value + item.price


func _on_inventory_item_focus_exited() -> void:
	equipment_bar_back.value = equipment_bar.value
	resource_bar_back.value = resource_bar.value


func _on_visibility_changed() -> void:
	if visible:
		activate(Globals.overworld.current_encounter)
	else:
		inventory.hide()
