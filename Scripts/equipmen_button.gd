extends MenuItem

@export var equipment_array: String
@export var slot_index: int
var original_text: String


func _ready() -> void:
	super._ready()
	original_text = text


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
