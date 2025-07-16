extends Node
class_name Menu

@export var item_container: MenuController


func activate():
	item_container.get_child(0).grab_focus()
