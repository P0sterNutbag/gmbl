extends Control
class_name MenuList

@export var item_container: MenuController
@export var pause_on_open: bool
signal exit


func _process(_delta: float) -> void:
	if !visible:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		close()


func open(array: Array):
	if pause_on_open:
		PlayerStats.change_state(PlayerStats.states.pause)
	item_container.delete_children()
	show()
	item_container.create_menu_items(array, on_button_pressed, on_button_focus_entered, false)


func close() -> void:
	UiController.close_interface(self, pause_on_open)
	exit.emit()
	#if pause_on_open:
		#PlayerStats.change_state(PlayerStats.states.walk)


func on_button_pressed(button: Control, resource: Resource) -> void:
	pass


func on_button_focus_entered(button: Control, resource: Resource) -> void:
	pass
