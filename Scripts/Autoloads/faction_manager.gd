extends Node

enum factions {no_faction, jackals, ragers, bandits}
@export var faction_relations := {
	factions.no_faction : {factions.no_faction : 1.0, factions.jackals : 0.0, factions.ragers : 0.0, factions.bandits : -1.0},
	factions.jackals : {factions.no_faction : 0.0, factions.jackals : 1.0, factions.ragers : -1.0, factions.bandits : -1.0},
	factions.ragers : {factions.no_faction : -1.0, factions.jackals : -1.0, factions.ragers : 1.0, factions.bandits : -1.0},
	factions.bandits : {factions.no_faction : -1.0, factions.jackals : -1.0, factions.ragers : -1.0, factions.bandits : 1.0}
}
var faction_display_names := {
	factions.no_faction : "Unaffiliated",
	factions.jackals : "Jackals",
	factions.ragers : "Ragers",
	factions.bandits : "Bandits",
}
var faction_colors := {
	factions.no_faction : Color(1.0, 1.0, 1.0, 1.0),
	factions.jackals: Color(0.0, 0.0, 1.0, 1.0),
	factions.ragers: Color(0.702, 0.0, 1.0, 1.0),
	factions.bandits: Color(0.866, 0.0, 0.0, 1.0)
}


func get_faction_relation(faction1: factions, faction2: factions) -> float:
	return faction_relations[faction1][faction2]


func change_faction_ration(faction1: factions, faction2: factions, amount: float) -> void:
	var current_relation = get_faction_relation(faction1, faction2)
	var new_relation = current_relation + amount
	faction_relations[faction1][faction2] = clamp(new_relation, -2, 2)
