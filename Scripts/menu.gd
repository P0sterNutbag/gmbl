extends Control
class_name Menu

@export var item_container: MenuController
@export var pause_on_open: bool


func activate():
	item_container.get_child(0).grab_focus()


func close() -> void:
	UiController.close_interface(self, pause_on_open)
