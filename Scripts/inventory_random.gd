extends Inventory
class_name InventoryRandom

@export var min_amount: int
@export var max_amount: int
@export var potential_slots: Array[SpawnChanceResource]


func _setup_local_to_scene() -> void:
	generate_inventory()


func generate_inventory() -> void:
	for i in randi_range(min_amount, max_amount):
		var item = potential_slots[Globals.get_weighted_index(potential_slots)].object_to_spawn
		add_item(item)
