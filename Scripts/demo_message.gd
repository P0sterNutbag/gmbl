extends PanelContainer

var has_fired: bool


func _ready() -> void:
	SaveController.load.connect(_on_load)
	PlayerStats.change_state(PlayerStats.states.pause)


func _process(_delta: float) -> void:
	if Input.is_anything_pressed():
		await get_tree().create_timer(0.1).timeout
		PlayerStats.change_state(PlayerStats.states.walk)
		has_fired = true
		hide()
		process_mode = PROCESS_MODE_DISABLED


func save() -> Dictionary:
	return {
		"has_fired" : has_fired,
	}


func _on_load() -> void:
	if has_fired:
		hide()
		process_mode = PROCESS_MODE_DISABLED
		PlayerStats.change_state(PlayerStats.states.walk)
