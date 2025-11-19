extends Node3D

@export var item_chances: Array[SpawnChanceResource]
@export var inventory: Inventory
@export var min_items: int
@export var max_items: int
@export var title = "Chest"


func _ready() -> void:
	if item_chances.size() > 0:
		for i in randi_range(min_items, max_items):
			var index = Globals.get_weighted_index(item_chances)
			inventory.add_item(item_chances[index].object_to_spawn)
