extends Resource
class_name LocationData

@export var faction: FactionManager.factions
@export var population: int
@export var min_population: int = 2
@export var max_population: int = 4
@export var loot_spawn_chance: float = 0.5
@export var squad_spawn_chance: float = 0.5
@export var trap_spawn_chance: float = 0.0


func change_population(amount: int) -> void:
	population = clamp(population + amount, min_population, max_population)
