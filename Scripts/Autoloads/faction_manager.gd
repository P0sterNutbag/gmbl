extends Node

enum factions {no_faction, player, jackals, ragers, bandits}
var faction_relations := {
	factions.player : {factions.no_faction : 0.0, factions.jackals : 0.0, factions.ragers : 0.0, factions.bandits : -1.0},
	factions.no_faction : {factions.player : 0.0, factions.jackals : 1.0, factions.ragers : 0.0, factions.bandits : -1.0},
	factions.jackals : {factions.player : 0.0, factions.no_faction : 1.0, factions.ragers : -1.0, factions.bandits : -1.0},
	factions.ragers : {factions.player : 0.0, factions.no_faction : 0.0, factions.jackals : -1.0, factions.bandits : -1.0},
	factions.bandits : {factions.player : -1.0, factions.no_faction : -1.0, factions.jackals : -1.0, factions.ragers : -1.0}
}
var faction_data := {
	factions.no_faction : preload("uid://cutkkksdpwkir"),
	factions.jackals : preload("uid://bgd28xhfo6e42"),
	factions.ragers : preload("uid://m1c0c8i8udgu"),
	factions.bandits : preload("uid://b3tbvkwwoh4lq"),
	factions.player : preload("uid://cutkkksdpwkir")
}
var max_score := 10.0


func get_faction_relation(faction1: factions, faction2: factions) -> float:
	if faction1 == faction2:
		return max_score
	return faction_relations[faction1][faction2]


func change_faction_relation(faction1: factions, faction2: factions, amount: float, create_notification: bool = false) -> void:
	var current_relation = get_faction_relation(faction1, faction2)
	var new_relation = current_relation + amount
	faction_relations[faction1][faction2] = clamp(new_relation, -10, 10)
	if create_notification and faction2 == factions.player and faction1 != factions.no_faction:
		var change = " decreased"
		if sign(amount) == 1:
			change = " increased"
		Globals.survival_ui.create_notification("Standing with " + faction_data[faction1].name + change)
