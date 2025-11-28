extends VBoxContainer

var index: int = -1
var can_advance: bool
var shop: Shop
var dialogue_tree: DialogueTree
var dialogue_bubble = preload("res://Scenes/Overworld/UI/dialogue_bubble.tscn")
var option_bubble = preload("res://Scenes/Overworld/UI/dialogue_options_bubble.tscn")
var menu_item = preload("res://Scenes/UI/menu_item.tscn")
@onready var label: Label = $"../PortraitHolder/HBoxContainer/NpcName"
signal exit


#func _ready() -> void:
	#visibility_changed.connect(_on_visibility_changed)


func _process(_delta: float) -> void:
	if !visible:
		return
	if (Input.is_action_just_pressed("select") or Input.is_action_just_pressed("shoot")) and dialogue_tree.bubbles[index] is not DialogueOptions and can_advance:
		advance_dialogue(index + 1)


func start_dialogue(tree: DialogueTree) -> void:
	index = -1
	for child in get_children():
		child.queue_free()
	Globals.ui.npc_portrait_model.set_materials(tree.npc_style)
	label.text = tree.npc_name
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
			inst2.pressed.connect(on_option_selected.bind(inst2))
			inst2.pressed.connect(advance_dialogue.bind(option.destination))
		inst.option_container.set_menu_item_focus()
		inst.option_container.get_child(0).grab_focus()
	if bubble is DialogueLoop:
		advance_dialogue(bubble.next_index)
	elif bubble is Dialogue:
		for line in bubble.lines:
			var inst = dialogue_bubble.instantiate()
			inst.size_flags_horizontal = SIZE_SHRINK_END
			add_child(inst)
			inst.text = line
	await get_tree().process_frame
	can_advance = true


func on_option_selected(option: Control) -> void:
	for child in get_child(-1).option_container.get_children():
		if child != option:
			child.queue_free()
		else:
			child._on_focus_exited()
			child.disabled = true
	get_child(-1).size.y = 0


#func _on_visibility_changed() -> void:
	#if visible:
		#index = -1
		#can_advance = false
		#Globals.ui.portraits.show()
		#PlayerStats.change_state(PlayerStats.states.pause)
	#else:
		#Globals.ui.portraits.hide()


func exit_to_game() -> void:
	Globals.ui.portraits.hide()
	UiController.close_interface(self)



#func exit_dialogue() -> void:
	#hide()
	#PlayerStats.change_state(PlayerStats.states.walk)


func enter_shop() -> void:
	hide()
	Globals.ui.enter_shop(shop)


func enter_town() -> void:
	hide()
	Globals.ui.town.re_enter_town()


func enter_job_board() -> void:
	hide()
	Globals.ui.town.enter_job_board()


func return_bounties() -> void:
	var complete_quests = PlayerStats.quests.filter(func(i): return i is QuestBounty and i.completed)
	if complete_quests.size() == 0:
		advance_dialogue(7)
		return
	var reward = 0
	for quest in complete_quests:
		PlayerStats.inventory.add_item(quest.reward)
		reward += quest.reward.amount
		PlayerStats.quests.erase(quest)
	dialogue_tree.bubbles[5].lines[0] += "($" +  str(reward) + ")"
	advance_dialogue(5)


func return_quests(quest_type: Quest, success_index: int, fail_index: int) -> void:
	for quest in PlayerStats.quests:
		if quest.has_method("check_complete"):
			quest.check_complete()
	var complete_quests = PlayerStats.quests.filter(func(i): return i.get_class() == quest_type.get_class() and i.return_location == Globals.ui.current_town.title and i.completed)
	if complete_quests.size() == 0:
		advance_dialogue(fail_index)
		return
	var reward = 0
	for quest in complete_quests:
		if quest.has_method("remove_items"):
			quest.remove_items()
		PlayerStats.inventory.add_item(quest.reward.item, quest.reward.amount)
		reward += quest.reward.amount
		PlayerStats.quests.erase(quest)
	dialogue_tree.bubbles[success_index].lines[0] += "($" +  str(reward) + ")"
	advance_dialogue(success_index)


func leave_shop() -> void:
	index = 1
	UiController.open_interface(self)
	advance_dialogue(index)
	#get_child(-1).option_container.get_child(0).grab_focus()
	
