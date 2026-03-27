extends Equipment


func equip() -> void:
	super.equip()
	if equipped:
		PlayerStats.gun_index = slot
	PlayerStats.gun_changed.emit()


func unequip() -> void:
	super.unequip()
	PlayerStats.gun_changed.emit()
