extends Resource
class_name LocationData

enum rarity_level {junk, common, rare, supreme}
@export var faction: FactionManager.factions 
@export var population: int
@export var min_population: int = 2
@export var max_population: int = 4
@export var loot_spawn_chance: float = 0.1
@export var loot_rarity: rarity_level
@export var npc_spawn_chance: float = 0.1
@export var trap_spawn_chance: float = 0.0


func change_population(amount: int) -> void:
	population = clamp(population + amount, min_population, max_population)
