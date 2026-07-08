extends VBoxContainer
class_name MenuController

var index: int
var menu_item = preload("res://Scenes/UI/menu_item.tscn")
const MENU_BUTTON = preload("uid://bj7gyfau2dx5w")


func add_button(scene: PackedScene) -> Control:
	var inst = scene.instantiate()
	add_child(inst)
	inst.focus_entered.connect(set_index.bind(inst))
	if inst is Button:
		inst.pressed.connect(select_last_button)
	return inst


func create_menu_button(parent = self) -> Control:
	var inst = MENU_BUTTON.instantiate()
	if parent != null:
		add_child(inst)
	inst.focus_entered.connect(set_index.bind(inst))
	inst.pressed.connect(select_last_button)
	return inst


func create_menu_item(parent = self, item_scene: PackedScene = menu_item) -> Control:
	var inst = item_scene.instantiate()
	if parent != null:
		add_child(inst)
	inst.focus_entered.connect(set_index.bind(inst))
	inst.pressed.connect(select_last_button)
	return inst


func create_menu_items(array: Array, item_scene: PackedScene = menu_item, on_pressed = null, on_focus = null, on_exit_focus = null, loop_focus: bool = true) -> Array:
	if array.size() <= 0:
		return []
	for i in array:
		var inst = create_menu_item(self, item_scene)
		inst.text = i.title
		#inst.custom_minimum_size.x = size.x
		if i is Resource:
			if on_pressed and on_pressed is Callable:
				inst.pressed.connect(on_pressed.bind(inst, i))
			if on_focus and on_focus is Callable:
				inst.focus_entered.connect(on_focus.bind(inst, i))
			if on_exit_focus:
				inst.focus_exited.connect(on_exit_focus.bind(inst))
	if loop_focus:
		set_menu_item_focus()
	await get_tree().process_frame
	if Input.get_connected_joypads().size() > 0:
		get_child(0).grab_focus()
	return get_children()


func set_menu_item_focus() -> void:
	get_child(0).focus_neighbor_top = get_child(-1).get_path()
	get_child(-1).focus_neighbor_bottom = get_child(0).get_path()


func delete_children() -> void:
	#index = 0
	for child in get_children():
		child.queue_free()


func set_index(button: Button):
	index = button.get_index()


func select_last_button() -> void:
	if !visible:
		return
	await get_tree().process_frame
	if get_child_count() == 0:
		return
	index = clamp(index, 0, get_child_count() - 1)
	if index < get_child_count():
		get_child(index).grab_focus()


func sort_menu_items() -> void:
	var sorted_children = get_children()
	sorted_children.sort_custom(func(a, b): return a.text.naturalnocasecmp_to(b.text) < 0)
	for child in get_children():
		move_child(child, sorted_children.find(child))
		child.focus_neighbor_top = NodePath("")
		child.focus_neighbor_bottom = NodePath("")
	set_menu_item_focus()
