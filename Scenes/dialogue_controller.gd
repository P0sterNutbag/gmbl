extends VBoxContainer

var index: int = -1
var can_advance: bool
var shop: Shop
var dialogue_tree: DialogueTree
var dialogue_bubble = preload("res://Scenes/Overworld/UI/dialogue_bubble.tscn")
var option_bubble = preload("res://Scenes/Overworld/UI/dialogue_options_bubble.tscn")
var menu_item = preload("res://Scenes/UI/menu_item.tscn")
signal exit

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)


func _process(delta: float) -> void:
	if !visible:
		return
	if Input.is_action_just_pressed("select") and dialogue_tree.bubbles[index] is not DialogueOptions and can_advance:
		advance_dialogue(index + 1)


func start_dialogue(tree: DialogueTree) -> void:
	for child in get_children():
		child.queue_free()
	Globals.overworld.npc_portrait_model.set_materials(tree.npc_style)
	dialogue_tree = tree
	advance_dialogue(index + 1)


func advance_dialogue(next_index: int) -> void:
	index = next_index
	var bubble = dialogue_tree.bubbles[index]
	if bubble is DialogueEvent:
		var callable = Callable(self, bubble.method)
		callable.callv(bubble.arguments)
	elif bubble is DialogueOptions:
		var inst = option_bubble.instantiate()
		inst.size_flags_horizontal = SIZE_SHRINK_BEGIN
		add_child(inst)
		for option in bubble.options:
			var inst2 = inst.option_container.create_menu_item()
			inst2.text = option.text
			inst2.pressed.connect(advance_dialogue.bind(option.destination))
		inst.option_container.set_menu_item_focus()
		inst.option_container.get_child(0).grab_focus()
	elif bubble is Dialogue:
		for line in bubble.lines:
			var inst = dialogue_bubble.instantiate()
			inst.size_flags_horizontal = SIZE_SHRINK_END
			add_child(inst)
			inst.text = line
	await get_tree().process_frame
	can_advance = true


func _on_visibility_changed() -> void:
	if visible:
		index = -1
		can_advance = false
		Globals.ui.portraits.show()
		PlayerStats.change_state(PlayerStats.states.pause)
	else:
		Globals.ui.portraits.hide()


func exit_dialogue() -> void:
	hide()
	PlayerStats.change_state(PlayerStats.states.walk)


func enter_shop() -> void:
	hide()
	Globals.ui.enter_shop(shop)


func enter_town() -> void:
	hide()
	Globals.ui.town.re_enter_town()


func _on_shop_exit() -> void:
	show()
	get_child(-1).option_container.get_child(0).grab_focus()
