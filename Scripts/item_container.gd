extends InteractableObject
class_name ItemContainer

@export var inventory: InventoryRandom


func _ready() -> void:
	actions = ["Loot"]


func interact() -> void:
	super.interact()
	Globals.survival_ui.loot(inventory)
	if Globals.overworld and Globals.overworld.current_encounter:
		if Globals.overworld.current_encounter.encounter_scene.resource_path == "res://Scenes/Levels/procgen_encounter.tscn":
			return
	var current_faction = get_tree().current_scene.location_data.faction
	var enemies = get_tree().get_nodes_in_group("enemies").filter(func(i): return i.faction == current_faction and FactionManager.get_faction_relation(i.faction, FactionManager.factions.player) >= 0)
	for enemy in enemies:
		if enemy.detection.can_see_target(Globals.player, true):
			FactionManager.change_faction_relation(current_faction, FactionManager.factions.player, -1, true)
			enemy.set_detection_targets()
			return
