extends PanelContainer


func _ready() -> void:
	PlayerStats.change_state(PlayerStats.states.pause)


func _process(_delta: float) -> void:
	if Input.is_anything_pressed():
		await get_tree().create_timer(0.1).timeout
		PlayerStats.change_state(PlayerStats.states.walk)
		queue_free()
