extends PanelContainer

var town_resource: Town
@onready var title: Label = $MarginContainer/VBoxContainer/Label
@onready var item_container: VBoxContainer = $MarginContainer/VBoxContainer/VBoxContainer


func _process(_delta: float) -> void:
	if !visible:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		exit()


func create_town(town_data: Town) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	PlayerStats.change_state(PlayerStats.states.pause)
	if town_data.shops.size() == 1:
		var shop = town_data.shops[0]
		Globals.ui.start_dialogue(shop.dialogue, shop)
		return
	Globals.ui.current_town = town_data
	town_resource = town_data
	item_container.delete_children()
	UiController.open_interface(self)
	#show()
	title.text = town_data.title
	for shop in town_data.shops:
		var menu = item_container.create_menu_item()
		menu.text = shop.title
		menu.alignment = BoxContainer.ALIGNMENT_CENTER
		if shop.quests.size() > 0:
			menu.pressed.connect(Globals.ui.job_board.set.bind("shop", shop))
			menu.pressed.connect(Globals.ui.start_dialogue.bind(shop.dialogue, shop))
		else:
			menu.pressed.connect(Globals.ui.start_dialogue.bind(shop.dialogue, shop))
		menu.pressed.connect(enter_shop)
	var inst = item_container.create_menu_item()
	inst.text = "Leave"
	inst.alignment = BoxContainer.ALIGNMENT_CENTER 
	inst.pressed.connect(exit)
	await Engine.get_main_loop().process_frame
	#item_container.get_child(0).grab_focus()
	item_container.set_menu_item_focus()


func exit():
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#PlayerStats.change_state(PlayerStats.states.walk)
	UiController.close_interface(self)
	#item_container.delete_children()
	#hide()


func enter_shop():
	#item_container.delete_children()
	hide()


func re_enter_town() -> void:
	#create_town(town_resource)
	show()
	get_parent().portraits.hide()


func enter_job_board() -> void:
	UiController.open_interface(Globals.ui.job_board)
	Globals.ui.job_board.open(Globals.ui.job_board.shop.quests)
