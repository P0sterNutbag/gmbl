extends MenuItem

@export var equipment_array: String
@export var slot: EquipmentKit.slots
var original_text: String
var equipment_kit: EquipmentKit


func _ready() -> void:
	super._ready()
	original_text = text
	equipment_kit = PlayerStats.inventory.equipment_kit


func _process(_delta: float) -> void:
	super._process(_delta)
	var item_name = ""
	var item = equipment_kit.equipment[slot]
	if item:
		item_name = item.title
	text = original_text + item_name


func _on_pressed() -> void:
	if equipment_array == "":
		return
	var item = equipment_kit.equipment[slot]
	if item:
		item.equip()


func _on_focus_entered() -> void:
	super._on_focus_entered()
	var item = equipment_kit.equipment[slot]
	Globals.survival_ui.player_inventory.set_description(item)


func _on_focus_exited() -> void:
	super._on_focus_exited()
	Globals.survival_ui.player_inventory.set_description()
