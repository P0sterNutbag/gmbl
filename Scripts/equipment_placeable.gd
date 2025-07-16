extends Equipment
class_name EquipmentPlaceable

@export var item_to_place: String


func equip() -> void:
	super.equip()
	for gun in PlayerStats.guns:
		gun.equipped = false
	equipped = !equipped
	if equipped:
		Globals.player.start_place_item(item_to_place)
	else:
		Globals.player.end_place_item()
	#Globals.player.change_gun_state(Globals.player.gun_states.no_gun)
