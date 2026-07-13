extends PanelContainer

var town_resource: Town
@onready var title: Label = $MarginContainer/VBoxContainer/Label
@onready var item_container: VBoxContainer = $MarginContainer/VBoxContainer/VBoxContainer
const SPACER = preload("uid://st2mrllebqci")


func _process(_delta: float) -> void:
	if !visible:
		return
	if Input.is_action_just_pressed("close"):
		exit()


func create_town(town_data: Town) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	#PlayerStats.change_state(PlayerStats.states.pause)
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
		var menu = item_container.create_menu_button()
		menu.text = shop.title
		menu.alignment = BoxContainer.ALIGNMENT_CENTER
		if shop is Shop:
			if shop.quests.size() > 0:
				menu.pressed.connect(Globals.ui.job_board.set.bind("shop", shop))
				menu.pressed.connect(Globals.ui.start_dialogue.bind(shop.dialogue, shop))
			elif shop.dialogue:
				menu.pressed.connect(Globals.ui.start_dialogue.bind(shop.dialogue, shop))
			else:
				menu.pressed.connect(Globals.ui.enter_shop.bind(shop))
			menu.pressed.connect(hide)
		elif shop is TownAction:
			menu.pressed.connect(shop.do_action)
			if shop.leave_town:
				menu.pressed.connect(hide)
		elif shop is QuestGiver:
			menu.pressed.connect(Globals.ui.job_board.set.bind("shop", shop))
			menu.pressed.connect(Globals.ui.start_dialogue.bind(shop.dialogue, shop))
			menu.pressed.connect(hide)
	var spacer = SPACER.instantiate()
	item_container.add_child(spacer)
	var inst = item_container.create_menu_button()
	inst.text = "Leave"
	inst.alignment = BoxContainer.ALIGNMENT_CENTER 
	inst.pressed.connect(exit)


func exit():
	UiController.close_interface(self)


func re_enter_town() -> void:
	#create_town(town_resource)
	show()
	get_parent().portraits.hide()


func enter_job_board(shop: TownOption) -> void:
	UiController.open_interface(Globals.ui.job_board)
	Globals.ui.job_board.shop = shop
	Globals.ui.job_board.open(shop.quests)
