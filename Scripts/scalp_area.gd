extends InteractableObject

const BLOODSPATTER = preload("uid://cqvgbxo1nn47e")


func interact():
	if !PlayerStats.inventory.find_item("knife"):
		Globals.survival_ui.create_notification("Missing knife")
		return
	owner.model.get_scalped()
	var inst = BLOODSPATTER.instantiate()
	get_parent().add_child(inst)
	inst.global_position = global_position
	owner.health_component.audio_stream_player.play()
	var scalp = FactionManager.faction_data[owner.faction].scalp.duplicate()
	PlayerStats.inventory.add_item(scalp, 1, true)
	#Globals.survival_ui.create_notification(scalp.title + "added to inventory")
	queue_free()
