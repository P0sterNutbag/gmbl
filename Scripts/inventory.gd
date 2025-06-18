extends Control
class_name Inventory

enum modes {use, loot}
@export var mode = modes.use
var index = 0
var target = PlayerStats
var target2
var menu_item = preload("res://Scenes/UI/menu_item.tscn")
@onready var item_container: VBoxContainer = %Items
@onready var title: Label = $MarginContainer/VBoxContainer/Label


func _process(delta: float) -> void:
	if !visible or !has_focus() or item_container.get_child_count() == 0:
		item_container.process_mode = Node.PROCESS_MODE_DISABLED
		return
	else:
		item_container.process_mode = Node.PROCESS_MODE_INHERIT
	
	# take all
	if Input.is_action_just_pressed("reload") and mode == modes.loot:
		for item in item_container.get_children():
			for amount in item.amount:
				target.items.erase(item.item)
				target2.items.append(item.item)
				item_container.remove_child(item)
		get_parent().reset_inventories()


func set_items():
	var old_items: Array
	if item_container.get_child_count() > 0:
		for child in item_container.get_children():
			child.queue_free()
	var items: Array
	for item in target.items:
		if item is not Equipment:
			var same_items = items.filter(func(i): return i.title == item.title)
			if same_items.size() > 0:
				var same_item = same_items[0]
				same_item.amount += 1
				continue
		var inst = menu_item.instantiate()
		inst.title = item.title
		inst.selected = false
		inst.item = item
		if mode == modes.use:
			inst.pressed.connect(item.use.bind(target))
		elif mode == modes.loot:
			inst.pressed.connect(transfer_item.bind(inst))
		items.append(inst)
	if items.size() == 0:
		return
	items.sort_custom(func(a, b): return a.title.casecmp_to(b.title) == -1)
	for item in items:
		item_container.add_child(item)
	await Engine.get_main_loop().process_frame
	if has_focus():
		index = clamp(index, 0, item_container.get_child_count() - 1)
		item_container.get_child(index).selected = true


func transfer_item(menu_item: Control):
	target.items.erase(menu_item.item)
	target2.items.append(menu_item.item)
	#item_container.remove_child(menu_item)
	get_parent().reset_inventories()


func remove_item(item: Item) -> void:
	target.items.erase(item)
	item_container.remove_child(item_container.get_child(index))
	set_items()


func _on_v_box_container_visibility_changed() -> void:
	if visible and get_parent().visible:
		set_items()
		if target is PlayerStats:
			title.text = "Inventory"
		else:
			title.text = target.title


func _on_focus_entered() -> void:
	if item_container.get_child_count() > 0:
		index = clamp(index, 0, item_container.get_child_count() - 1)
		item_container.get_child(index).selected = true


func _on_focus_exited() -> void:
	if item_container.get_child_count() > 0:
		index = clamp(index, 0, item_container.get_child_count() - 1)
		item_container.get_child(index).selected = false
