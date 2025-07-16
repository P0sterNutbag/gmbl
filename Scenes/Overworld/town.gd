extends PanelContainer

var town_resource: Town
@onready var title: Label = $MarginContainer/VBoxContainer/Label
@onready var item_container: VBoxContainer = $MarginContainer/VBoxContainer/VBoxContainer


func _process(delta: float) -> void:
	if !visible:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		exit()


func create_town(town_data: Town) -> void:
	PlayerStats.change_state(PlayerStats.states.pause)
	if town_data.shops.size() == 1:
		var shop = town_data.shops[0]
		Globals.ui.start_dialogue(shop.dialogue, shop)
		return
	Globals.ui.current_town = town_data
	town_resource = town_data
	item_container.delete_children()
	show()
	title.text = town_data.title
	for shop in town_data.shops:
		var inst = item_container.create_menu_item()
		inst.text = shop.title
		inst.alignment = BoxContainer.ALIGNMENT_CENTER
		if shop.quests.size() > 0:
			inst.pressed.connect(Globals.ui.bounty_board.set.bind("shop", shop))
			inst.pressed.connect(Globals.ui.start_dialogue.bind(shop.dialogue, shop))
			#inst.pressed.connect(Globals.ui.bounty_board.open.bind(shop.quests))
		else:
			inst.pressed.connect(Globals.ui.start_dialogue.bind(shop.dialogue, shop))
		inst.pressed.connect(enter_shop)
	var inst = item_container.create_menu_item()
	inst.text = "Leave"
	inst.alignment = BoxContainer.ALIGNMENT_CENTER 
	inst.pressed.connect(exit)
	await Engine.get_main_loop().process_frame
	item_container.get_child(0).grab_focus()
	item_container.set_menu_item_focus()


func exit():
	PlayerStats.change_state(PlayerStats.states.walk)
	item_container.delete_children()
	hide()


func enter_shop():
	item_container.delete_children()
	hide()


func re_enter_town() -> void:
	create_town(town_resource)


func enter_bounty_board() -> void:
	Globals.ui.bounty_board.open(Globals.ui.bounty_board.shop.quests)
