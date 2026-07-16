extends VBoxContainer

var index := -1
var last_option_index: int
var can_advance: bool
var shop: TownOption
var dialogue_tree: DialogueTree
var dialogue_branch: DialogueBranch
var dialogue_bubble = preload("res://Scenes/Overworld/UI/dialogue_bubble.tscn")
var option_bubble = preload("res://Scenes/Overworld/UI/dialogue_options_bubble.tscn")
var menu_item = preload("res://Scenes/UI/menu_item.tscn")
@onready var label: Label = $"../PortraitHolder/HBoxContainer/NpcName"
@onready var repair_menu: Control = $"../Repair"


func _process(_delta: float) -> void:
	if !visible:
		return
	var current_bubble = get_child(-1)
	if ((Input.is_action_just_pressed("select") or Input.is_action_just_pressed("shoot")) and "option_container" not in current_bubble and can_advance
	and current_bubble.can_proceed):
		advance_dialogue(index + 1)
	#if Input.is_action_just_pressed("ui_cancel") and dialogue_tree.bubbles[index] is DialogueOptions:
		#if Globals.overworld.current_encounter.town:
			#enter_town()
		#else:
			#exit_dialogue()


func start_dialogue(tree: DialogueTree) -> void:
	index = -1
	for child in get_children():
		child.queue_free()
	Globals.ui.npc_portrait_model.set_materials(tree.npc_style)
	var camera_pivot = Globals.ui.npc_portrait_model.get_parent().get_child(-1)
	camera_pivot.rotation.y = deg_to_rad(tree.camera_angle)
	label.text = tree.npc_name
	dialogue_tree = tree
	dialogue_branch = null
	advance_dialogue(index + 1)


func advance_dialogue(next_index: int = index + 1) -> void:
	var bubble
	index = next_index
	if dialogue_branch:
		if index > dialogue_branch.bubbles.size() - 1:
			index = last_option_index
			bubble = dialogue_tree.bubbles[index]
		else:
			bubble = dialogue_branch.bubbles[index]
	else:
		bubble = dialogue_tree.bubbles[index]
	if bubble is DialogueEvent:
		var callable = Callable(self, bubble.method)
		callable.callv(bubble.arguments)
	elif bubble is DialogueConditionLine:
		var _text: String
		if bubble.is_condition_true():
			_text = bubble.success_text
		else:
			_text = bubble.fail_text
		var inst = dialogue_bubble.instantiate()
		inst.size_flags_horizontal = SIZE_SHRINK_END
		add_child(inst)
		inst.start_typewriter(_text)
	elif bubble is DialogueConditionVariable:
		if bubble.is_condition_true():
			dialogue_branch = bubble.success_branch
			advance_dialogue(0)
		else:
			dialogue_branch = bubble.failure_branch
			advance_dialogue(0)
	elif bubble is DialogueConditionMethod:
		var result = callv(bubble.method, bubble.arguments)
		if result:
			dialogue_branch = bubble.success_branch
			advance_dialogue(0)
		else:
			dialogue_branch = bubble.failure_branch
			advance_dialogue(0)
	elif bubble is DialogueOptions:
		var inst = option_bubble.instantiate()
		inst.size_flags_horizontal = SIZE_SHRINK_BEGIN
		add_child(inst)
		for option in bubble.options:
			var option_button = inst.option_container.create_menu_button()
			option_button.text = option.text
			option_button.pressed.connect(on_option_selected.bind(option, option_button))
			#inst2.pressed.connect(advance_dialogue.bind(option.destination))
		inst.option_container.set_menu_item_focus()
		last_option_index = index
		#if Input.get_connected_joypads().size() > 0:
			#inst.option_container.get_child(0).grab_focus()
	#if bubble is DialogueLoop:
		#advance_dialogue(bubble.next_index)
	if bubble is Dialogue:
		var inst = dialogue_bubble.instantiate()
		inst.size_flags_horizontal = SIZE_SHRINK_END
		add_child(inst)
		inst.start_typewriter(bubble.text)
	await get_tree().process_frame
	can_advance = true


func on_option_selected(option: DialogueBranch, option_button: Control) -> void:
	for child in get_child(-1).option_container.get_children():
		if child != option_button:
			child.queue_free()
		else:
			child._on_focus_exited()
			child.disabled = true
	dialogue_branch = option
	advance_dialogue(0)
	get_child(-1).size.y = 0


#func _on_visibility_changed() -> void:
	#if visible:
		#index = -1
		#can_advance = false
		#Globals.ui.portraits.show()
		#PlayerStats.change_state(PlayerStats.states.pause)
	#else:
		#Globals.ui.portraits.hide()


func exit_dialogue() -> void:
	Globals.ui.portraits.hide()
	UiController.close_interface(self)
	Globals.overworld.current_encounter.encounter_ended.emit()


func enter_shop() -> void:
	hide()
	if !shop:
		shop = Globals.overworld.current_encounter.shop
	Globals.ui.enter_shop(shop)


func enter_town() -> void:
	hide()
	Globals.ui.portraits.hide()
	Globals.ui.town.re_enter_town()


func enter_job_board() -> void:
	hide()
	Globals.ui.town.enter_job_board(shop)


#func return_bounties() -> void:
	#var complete_quests = PlayerStats.quests.filter(func(i): return i is QuestBounty and i.completed)
	#if complete_quests.size() == 0:
		#advance_dialogue(7)
		#return
	#var reward = 0
	#for quest in complete_quests:
		#PlayerStats.inventory.add_item(quest.reward)
		#reward += quest.reward.amount
		#PlayerStats.quests.erase(quest)
		#ProgressManager.quests_completed += 1
	#dialogue_tree.bubbles[5].lines[0] += "($" +  str(reward) + ")"
	#advance_dialogue(5)


func return_quests() -> void:
	var complete_quests = PlayerStats.quests.filter(func(i): return i.return_location == Globals.overworld.current_encounter.title and i.completed)
	for quest in complete_quests:
		quest.finish_quest(shop.faction)
		if quest.has_method("remove_items"):
			quest.remove_items()
		PlayerStats.inventory.add_item(quest.reward.item, quest.reward.amount)
		Globals.survival_ui.create_notification("'" + quest.title + "' completed. " + "You gained $" + str(quest.reward.amount))
		PlayerStats.quests.erase(quest)
	advance_dialogue()


func has_completed_quests() -> bool:
	for quest in PlayerStats.quests:
		if quest.has_method("check_complete"):
			quest.check_complete()
	var complete_quests = PlayerStats.quests.filter(func(i): return i.return_location == Globals.overworld.current_encounter.title and i.completed)
	return complete_quests.size() > 0


func leave_shop() -> void:
	await get_tree().process_frame
	dialogue_branch = null
	index = 1
	UiController.open_interface(self)
	advance_dialogue(index)


func enter_level(start_alert: bool = false) -> void:
	Globals.ui.portraits.hide()
	UiController.close_interface(self)
	#var start_alert = FactionManager.get_faction_relation(Globals.overworld.current_encounter.location_data.faction, FactionManager.factions.player) < 0
	Globals.overworld.current_encounter.alert_enemies = start_alert
	Globals.overworld.current_encounter.transition_to_level()


func change_scene(scene_path: String) -> void:
	SceneManager.start_scene_transition(scene_path, true)


func pay_fee(amount: int) -> void:
	PlayerStats.inventory.money -= amount
	var parent = Globals.overworld.current_encounter.get_parent()
	if parent is CharacterBody3D:
		parent.chase_player = false
		parent.navigation_agent.set_target_position(parent.destination.global_position)
	Globals.survival_ui.create_notification("You payed $" + str(amount))
	advance_dialogue(index + 1)


func enter_repair_menu() -> void:
	UiController.open_subinterface(repair_menu)


func set_recruit_price() -> void:
	var location_data = Globals.overworld.current_encounter.location_data
	var amount = 150
	amount -= FactionManager.get_faction_relation(location_data.faction, FactionManager.factions.player) * 10
	dialogue_tree.bubbles[index + 1].options[0].value2 = amount - 1
	dialogue_tree.bubbles[index + 1].options[0].text = "Pay " + "($" + str(amount) + ")"
	dialogue_tree.bubbles[index + 2].arguments[0] = amount


func recruit_npc(amount: int) -> void:
	PlayerStats.inventory.money -= amount
	var location_data = Globals.overworld.current_encounter.location_data
	location_data.population = clamp(location_data.population - 1, 1, 100)
	var npc_data = NpcData.new()
	npc_data.style = FactionManager.faction_data[Globals.overworld.current_encounter.location_data.faction].style.generate_style()
	PlayerStats.allies.append(NpcData.new())
	Globals.survival_ui.create_notification("You payed $" + str(amount))
	Globals.survival_ui.create_notification("Ally added to party")
	advance_dialogue(index + 1)


func move_player(dest: Vector3) -> void:
	hide()
	PlayerStats.inventory.money -= 2000
	Globals.survival_ui.create_notification("You payed $2000")
	var anim_player = SceneManager.scene_transition.animation_player
	anim_player.play("fade_in")
	await anim_player.animation_finished
	Globals.player.position = dest
	await get_tree().create_timer(1.0).timeout
	anim_player.play("fade_out")
	await anim_player.animation_finished
	exit_dialogue()


func talk_to_npc() -> void:
	#Globals.ui.start_dialogue(Globals.overworld.current_encounter.dialogue_tree)
	var npc_location = Globals.overworld.current_encounter
	var unaware_dialogue_tree = npc_location.unaware_dialogue_tree
	npc_location.unaware_dialogue_tree = null
	npc_location.start_encounter()
	await get_tree().process_frame
	npc_location.unaware_dialogue_tree = unaware_dialogue_tree


func create_notification(text: String) -> void:
	Globals.survival_ui.create_notification(text)
	advance_dialogue()


func shop_has_quests() -> bool:
	return shop.quests.size() > 0


func surrender_to_enemy() -> void:
	PlayerStats.inventory.money = 0
	PlayerStats.inventory.item_slots.clear()
	Globals.survival_ui.create_notification("All money and items lost")
	var npc = Globals.overworld.current_encounter.get_parent()
	npc.chase_player = false
	npc.navigation_agent.set_target_position(npc.destination.global_position)
	advance_dialogue()


func _exit_tree() -> void:
	UiController.close_interface(self)
