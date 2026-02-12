extends MenuItem

@export var slot: EquipmentKit.slots
var original_text: String
var equipment: Equipment


func _ready() -> void:
	super._ready()
	original_text = text
	#PlayerStats.gun_changed.connect(_on_gun_changed)


func _process(_delta: float) -> void:
	super._process(_delta)
	var kit = PlayerStats.inventory.equipment_kit
	var equipment_name = ""
	equipment = kit.equipment[slot]
	if equipment:
		equipment_name = equipment.title
	text = original_text + equipment_name
	if Input.is_action_just_pressed("drop_item") and has_focus():
		pressed.emit()


func _on_pressed() -> void:
	super._on_pressed()
	if equipment:
		equipment.unquip()


func _on_focus_entered() -> void:
	super._on_focus_entered()
	Globals.survival_ui.player_inventory.set_description(equipment)


func _on_focus_exited() -> void:
	super._on_focus_exited()
	Globals.survival_ui.player_inventory.set_description()


#func _on_gun_changed() -> void:
	#amount = resource.amount
