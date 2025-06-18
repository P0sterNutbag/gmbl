extends VBoxContainer

var index: int
var can_move: bool = true
var menu_item = preload("res://Scenes/UI/menu_item.tscn")


func _process(delta: float) -> void:
	if !visible:
		return
	var dir: int = Input.get_axis("ui_up", "ui_down")
	if dir and get_child_count()-1 > 0 and can_move:
		get_child(index).selected = false
		index = wrapi(index + dir, 0, get_child_count())
		get_child(index).selected = true
		can_move = false
	if dir == 0:
		can_move = true


func create_menu_item() -> Control:
	var inst = menu_item.instantiate()
	inst.selected = false
	add_child(inst)
	return inst


func delete_children() -> void:
	index = 0
	for child in get_children():
		child.selected = false
		child.queue_free()
