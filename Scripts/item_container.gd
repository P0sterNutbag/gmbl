extends InteractableObject
class_name ItemContainer

@export var inventory: Inventory
@export var action_verb: String = "Loot"
@export var conditions: Array[Condition]
@export_multiline() var error_message: String
@export var locked_chance: float
var locked: bool


func _ready() -> void:
	if randf() < locked_chance:
		locked = true
	if locked:
		actions = ["Pick Lock"]
	else:
		actions = [action_verb]


func interact() -> void:
	super.interact()
	for condition in conditions:
		if !condition.is_met():
			Globals.survival_ui.create_notification(error_message)
			return
	if locked:
		if PlayerStats.inventory.find_item("lockpick"):
			PlayerStats.inventory.remove_item_by_name("lockpick", 1, true)
			locked = false
			actions = ["Loot"]
		else:
			Globals.survival_ui.create_notification("You don't have any lockpicks")
	else:
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
