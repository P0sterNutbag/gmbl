extends VBoxContainer

var upgrade_cost: int
@onready var level_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Label2
@onready var cost_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Label2
@onready var money_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/Label2
@onready var pay_button: Button = $HBoxContainer/PanelContainer2/MarginContainer/Pay


func activate() -> void:
	var location_data = Globals.overworld.current_encounter.location_data
	level_label.text = str(location_data.firepower + 1)
	upgrade_cost = 100 + location_data.firepower * 50
	cost_label.text = "$" + str(upgrade_cost)
	money_label.text = "$" + str(PlayerStats.money)
	pay_button.disabled = PlayerStats.money < upgrade_cost


func _on_pay_pressed() -> void:
	var location_data = Globals.overworld.current_encounter.location_data
	location_data.firepower += 1
	location_data.armor_level = location_data.firepower
	PlayerStats.inventory.money -= upgrade_cost
	activate()
	#UiController.close_subinterface()


func _on_exit_pressed() -> void:
	UiController.close_subinterface()


func _on_visibility_changed() -> void:
	if visible:
		activate()
