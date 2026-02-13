extends Inventory
class_name InventoryRandom

@export var min_amount: int
@export var max_amount: int
@export var potential_slots: Array[SpawnChanceResource]
@export var min_condition: float = 0.1
@export var max_condition: float = 0.3


func _setup_local_to_scene() -> void:
	generate_inventory()


func generate_inventory() -> void:
	var amount_to_add = randi_range(min_amount, max_amount)
	for i in amount_to_add:
		add_random_item()


func add_random_item() -> void:
	var spawn_resource = potential_slots[Globals.get_weighted_index(potential_slots)]
	var item = spawn_resource.object_to_spawn.duplicate_deep()
	if "condition" in item:
		item.condition = randf_range(min_condition, max_condition)
	for i in randi_range(spawn_resource.min_amount, spawn_resource.max_amount):
		add_item(item)


func restock_inventory() -> void:
	var amount_to_add = randi_range(min_amount, max_amount)
	amount_to_add -= items.size()
	for i in amount_to_add:
		add_random_item()
