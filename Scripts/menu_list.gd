extends Control
class_name MenuList

@export var item_container: MenuController
@export var pause_on_open: bool
@export var is_subinterface: bool
signal exit


func open(array: Array, button_scene: PackedScene = item_container.menu_item):
	if pause_on_open:
		PlayerStats.change_state(PlayerStats.states.pause)
	item_container.delete_children()
	show()
	item_container.create_menu_items(array, button_scene, on_button_pressed, on_button_focus_entered, on_button_focus_exited, false)


func close() -> void:
	if is_subinterface:
		UiController.close_subinterface()
	else:
		UiController.close_interface(self, pause_on_open)
	exit.emit()


@warning_ignore("unused_parameter")
func on_button_pressed(button: Control, resource: Resource) -> void:
	pass


@warning_ignore("unused_parameter")
func on_button_focus_entered(button: Control, resource: Resource) -> void:
	var i = 0
	pass


@warning_ignore("unused_parameter")
func on_button_focus_exited(button: Control) -> void:
	var i = 0
	pass
