extends Control
class_name Menu

@export var item_container: MenuController
@export var pause_on_open: bool


func activate():
	visible = true
	for child in item_container.get_children():
		if child.visible:
			child.grab_focus()
			return


func close() -> void:
	UiController.close_interface(self, pause_on_open)
