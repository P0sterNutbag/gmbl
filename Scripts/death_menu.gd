extends Menu

@onready var tourniquet_button: UiButton = $MarginContainer/VBoxContainer3/VBoxContainer/TourniquetButton
@onready var morphine_button: UiButton = $MarginContainer/VBoxContainer3/VBoxContainer/MorphineButton
var torniquet_item: ItemUsable = preload("uid://cf41qwurikia4")
var morphine_item: ItemUsable = preload("uid://bbx4x21dta7e7")


func activate() -> void:
	var torniquet_amount = PlayerStats.inventory.get_item_amount(torniquet_item)
	tourniquet_button.text = torniquet_item.title +  "(x" + str(torniquet_amount) + ")"
	tourniquet_button.disabled = torniquet_amount == 0
	var morphine_amount = PlayerStats.inventory.get_item_amount(morphine_item)
	morphine_button.text = morphine_item.title + "(x" + str(morphine_amount) + ")"
	morphine_button.disabled = morphine_amount == 0


func _on_tourniquet_button_pressed() -> void:
	var item = PlayerStats.inventory.find_item(torniquet_item.title)
	item.use(Globals.player.hitbox)
	revive_player()


func _on_morphine_button_pressed() -> void:
	var item = PlayerStats.inventory.find_item(morphine_item.title)
	item.use(Globals.player.hitbox)
	revive_player()


func revive_player() -> void:
	#PlayerStats.change_state(PlayerStats.states.walk)
	UiController.close_interface(self)


func _on_give_up_button_pressed() -> void:
	PlayerStats.give_up()
	UiController.open_interface(Globals.survival_ui.progress_menu, false, true)
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#Globals.overworld.player_died = true
	#SceneManager.start_scene_transition(Globals.overworld)


func _on_visibility_changed() -> void:
	if visible:
		activate()
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
