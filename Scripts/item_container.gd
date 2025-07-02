extends Node3D

@export var items: Array[Item]
@export var item_chances: Array[SpawnChanceResource]
@export var min_items: int
@export var max_items: int
var title = "Chest"


func _ready() -> void:
	if item_chances.size() > 0:
		for i in randi_range(min_items, max_items):
			var index = Globals.get_weighted_index(item_chances)
			items.append(item_chances[index].object_to_spawn)
