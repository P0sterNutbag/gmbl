extends MenuItem

@export var equipment_array: String
@export var slot_index: int
var original_text: String


func _ready() -> void:
	super._ready()
	original_text = text
	#focus_entered.connect(Globals.ui.player_inventory.set_description.bind(resource.item))


func _process(_delta: float) -> void:
	super._process(_delta)
	if equipment_array == "":
		return
	var equipment_name = ""
	var equipment = PlayerStats.get(equipment_array)[slot_index]
	if equipment:
		equipment_name = equipment.title
	text = original_text + equipment_name


func _on_pressed() -> void:
	if equipment_array == "":
		return
	var equipment = PlayerStats.get(equipment_array)[slot_index]
	if equipment:
		equipment.equip()


func _on_focus_entered() -> void:
	super._on_focus_entered()
	var equipment = PlayerStats.get(equipment_array)[slot_index]
	#if equipment: 
	Globals.survival_ui.player_inventory.set_description(equipment)


func _on_focus_exited() -> void:
	super._on_focus_exited()
	Globals.survival_ui.player_inventory.set_description()
