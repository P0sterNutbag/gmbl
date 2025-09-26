extends Resource
class_name LocationData

enum rarity_level {junk, common, rare, supreme}
@export var population: int
@export var loot_spawn_chance: float = 0.1
@export var loot_rarity: rarity_level
@export var npc_spawn_chance: float = 0.1
