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
	town_resource = town_data
	item_container.delete_children()
	show()
	PlayerStats.change_state(PlayerStats.states.pause)
	title.text = town_data.title
	for shop in town_data.shops:
		var inst = item_container.create_menu_item()
		inst.title = shop.title
		inst.alignment = BoxContainer.ALIGNMENT_CENTER 
		inst.pressed.connect(Globals.ui.enter_shop.bind(shop))
		inst.pressed.connect(enter_shop)
	var inst = item_container.create_menu_item()
	inst.title = "Leave"
	inst.alignment = BoxContainer.ALIGNMENT_CENTER 
	inst.pressed.connect(exit)
	await Engine.get_main_loop().process_frame
	item_container.get_child(0).selected = true


func exit():
	PlayerStats.change_state(PlayerStats.states.walk)
	item_container.delete_children()
	hide()


func enter_shop():
	item_container.delete_children()
	hide()


func _on_shop_exit() -> void:
	create_town(town_resource)
