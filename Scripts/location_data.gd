extends Resource
class_name LocationData

@export var faction: FactionManager.factions = FactionManager.factions.no_faction
@export var population: int
@export var max_population: int = 4
@export var loot_spawn_chance: float = 0.5
@export var squad_spawn_chance: float = 0.5
@export var trap_spawn_chance: float = 0.0


func change_population(amount: int) -> void:
	population = clamp(population + amount, 0, max_population)
