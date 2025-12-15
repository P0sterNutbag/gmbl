extends Inventory
class_name InventoryRandom

@export var min_amount: int
@export var max_amount: int
@export var potential_slots: Array[SpawnChanceResource]


func _setup_local_to_scene() -> void:
	generate_inventory()


func generate_inventory() -> void:
	for i in randi_range(min_amount, max_amount):
		var spawn_resource = potential_slots[Globals.get_weighted_index(potential_slots)]
		var item = spawn_resource.object_to_spawn
		for y in randi_range(spawn_resource.min_amount, spawn_resource.max_amount):
			add_item(item)
