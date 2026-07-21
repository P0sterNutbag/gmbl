extends Resource
class_name LocationData

#@export var title: String
@export var faction: FactionManager.factions = FactionManager.factions.no_faction
@export var population: int
@export var max_population: int = 4
@export var loot_spawn_chance: float = 0.5
@export var squad_spawn_chance: float = 0.5
@export var trap_spawn_chance: float = 0.0
@export var income_amount := 0
@export var firepower := 0
@export var firepower_chance = [1.0, 0.0, 0.0]
@export var armor_level = 0
@export var armor_level_chance = [1.0, 0.0, 0.0, 0.0]
@export_storage var current_buildings : Array[Building]
@export_storage var available_buildings : Array[Building] = [
	preload("uid://b5jq04vjhbesn"),
	preload("uid://ctgs5b2ersn74"),
	preload("uid://bvarqtik12eep")
]


func change_population(amount: int = 1) -> void:
	population = clamp(population + amount, 0, max_population)
