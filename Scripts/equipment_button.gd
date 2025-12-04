extends MenuItem

@export var slot: EquipmentKit.slots
var original_text: String
var equipment: Equipment


func _ready() -> void:
	super._ready()
	original_text = text


func _process(_delta: float) -> void:
	super._process(_delta)
	var kit = PlayerStats.inventory.equipment_kit
	var equipment_name = ""
	equipment = kit.equipment[slot]
	if equipment:
		equipment_name = equipment.title
	text = original_text + equipment_name


func _on_pressed() -> void:
	if equipment:
		equipment.equip()


func _on_focus_entered() -> void:
	super._on_focus_entered()
	Globals.survival_ui.player_inventory.set_description(equipment)


func _on_focus_exited() -> void:
	super._on_focus_exited()
	Globals.survival_ui.player_inventory.set_description()
