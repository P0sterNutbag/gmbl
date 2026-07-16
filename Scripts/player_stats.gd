extends Node

@export var starting_inventory: Inventory
@export var allies: Array[NpcData]
@export var player_style := preload("uid://b4ypcwfcexyed")
enum states {walk, pause, dead}
var state = states.walk
var faction: FactionManager.factions: 
	set(value):
		faction = value
		if Globals.player:
			Globals.player.faction = value
var hp: float = 3.5
var current_hp: float:
	get():
		if Globals.player and "hitbox" in Globals.player and Globals.player.hitbox:
			return Globals.player.hitbox.hp
		else:
			return hp
var max_current_hp := 3.5
var player_name: String = "Player"
var sensitivity_modifier := 1.0
var ammo: int:
	set(value):
		ammo = value
		if gun:
			gun.gun_stats.ammo = value
	get():
		if gun:
			return gun.gun_stats.ammo
		else:
			return 0
var money: int:
	get():
		return inventory.money
var max_allies := 4
var flashlight_on: bool
var allies_shoot: bool = true
var gun_index: int = 0
var sleep: float
var hunger: float
var thirst: float
var soberness: float = 1.0
var max_sleep: float
var max_hunger: float
var max_thirst: float
var max_soberness: float = 1.0
var sleep_decrease_rate := 0.2
var hunger_decrease_rate := 0.2
var thirst_decrease_rate := 0.25
var skill_points := 3.0
var arena_level := 0
var shooting_level := 0
var saved_style: NpcStyle
var gun: Equipment
var skills: CharacterSkills
var inventory: Inventory = Inventory.new()
var quests: Array[Quest]
var ally_npcs: Array[Npc]
var save_guns: Array[Item]
@onready var guns: Array[Item]:
	get(): 
		return inventory.items.filter(func(i): return i is EquipmentGun)
signal gun_changed
signal sleep_finished


func _ready() -> void:
	reset_stats()
	SceneManager.scene_changed.connect(_on_scene_changed)
	SceneManager.scene_leaving.connect(_on_scene_leaving)
	SaveController.load.connect(_on_load)
	gun_changed.connect(_on_gun_changed)
	await get_tree().process_frame
	max_sleep = DayNightCycle.day_length / (sleep_decrease_rate * abs(DayNightCycle.time_speed))
	max_hunger = DayNightCycle.day_length / (hunger_decrease_rate * abs(DayNightCycle.time_speed))
	max_thirst = DayNightCycle.day_length / (thirst_decrease_rate * abs(DayNightCycle.time_speed))
	sleep = max_sleep
	hunger = max_hunger
	thirst = max_thirst
	faction = FactionManager.factions.player
	inventory.space_modifier = int(skills.strength)
	inventory.resource_local_to_scene = true
	#sensitivity_modifier = ConfigManager.file.get_value("settings", "mouse_sensitivity", sensitivity_modifier)


func _process(delta: float) -> void:
	if !get_tree().current_scene:
		return
	var scene_name = get_tree().current_scene.name
	if scene_name == "CharacterCreation" or scene_name == "MainMenu":# or !Globals.overworld:
		return
	# survival stats
	sleep = clamp(sleep - delta, 0, max_sleep)
	hunger = clamp(hunger - delta, 0, max_hunger)
	thirst = clamp(thirst - delta , 0, max_thirst)
	if Globals.player and (hunger <= 0 or thirst <= 0) and Globals.player.hitbox.hp > 0.1:
		#Globals.player.hitbox.damage(0.025 * delta, Vector3.ZERO, Vector3.ZERO, false, false, false)
		Globals.player.hitbox.hp -= 0.01 * delta
	if soberness < max_soberness:
		soberness += delta * 0.01


func _physics_process(delta):
	# state machine
	if !Globals.player or !get_tree().current_scene:
		return
	if Globals.player.process_mode == PROCESS_MODE_DISABLED or get_tree().current_scene.process_mode == PROCESS_MODE_DISABLED:
		return
	if Globals.player.state_functions.has(PlayerStats.state):
		Globals.player.state_functions[PlayerStats.state].call(delta)


func reset_stats() -> void:
	inventory.equipment_kit.remove_all()
	inventory = starting_inventory.duplicate(true)
	skills = CharacterSkills.new()
	skill_points = 3
	quests.clear()
	hp = max_current_hp
	sleep = max_sleep
	hunger = max_hunger
	thirst = max_thirst


func change_state(new_state):
	if !Globals.player:
		return
	if Globals.player.exit_functions.has(PlayerStats.state):
		await Globals.player.exit_functions[PlayerStats.state].call()
	PlayerStats.state = new_state
	if Globals.player.enter_functions.has(PlayerStats.state):
		await Globals.player.enter_functions[PlayerStats.state].call()


func unequip_current_item():
	for slot in inventory.items_slots:
		var item = slot.item
		if item is Equipment:
			item.equipped = false


func delete_current_equip():
	for slot in inventory.items_slots:
		var item = slot.item
		if item is Equipment and item.equipped:
			inventory.items_slots.remove_item(item)


func reload_gun() -> void:
	Globals.player.gun.ammo = Globals.player.gun.max_ammo


func decrease_hunger(new_value: float) -> void:
	var hunger_amount = hunger / max_hunger
	var new_amount = clamp(hunger_amount + new_value, 0, max_hunger)
	hunger = max_hunger * new_amount


func decrease_thirst(new_value: float) -> void:
	var thirst_amount = thirst / max_thirst
	var new_amount = clamp(thirst_amount + new_value, 0, max_thirst)
	thirst = max_thirst * new_amount


func decrease_sleep(new_value: float) -> void:
	var sleep_amount = sleep / max_sleep
	var new_amount = clamp(sleep_amount + new_value, 0, max_sleep)
	sleep = max_sleep * new_amount


func go_to_sleep(time_to_skip: float = 1.5):
	var enemies := []
	enemies.append_array(get_tree().get_nodes_in_group("enemies"))
	enemies.append_array(get_tree().get_nodes_in_group("overworld_npcs"))
	for enemy in enemies:
		if enemy.target == Globals.player or enemy.global_position.distance_to(Globals.player.global_position) < 25.0:
			Globals.survival_ui.create_notification("Unable to sleep with enemies nearby")
			return
		if get_tree().current_scene != Globals.overworld and enemy.global_position.distance_to(Globals.player.global_position) < 25.0:
			Globals.survival_ui.create_notification("Unable to sleep with enemies nearby")
			return
	#if get_tree().current_scene != Globals.overworld:
		#return
	UiController.close_interface(Globals.survival_ui.menu_holder)
	change_state(states.pause)
	var tween = create_tween()
	tween.tween_callback(SceneManager.animation_player.play.bind("fade_in"))
	tween.tween_callback(DayNightCycle.skip_to_time.bind(time_to_skip))
	tween.tween_callback(SceneManager.animation_player.play.bind("fade_out")).set_delay(2)
	tween.tween_callback(progress_npcs)
	tween.tween_property(self, "sleep", max_sleep, 0)
	tween.tween_property(self, "soberness", max_soberness, 0)
	tween.tween_callback(decrease_thirst.bind(-0.3))
	tween.tween_callback(decrease_hunger.bind(-0.3))
	tween.tween_property(Globals.player.hitbox, "hp", Globals.player.hitbox.hp + 0.5, 0)
	if !UiController.is_canvas_layer_open(Globals.ui):
		tween.tween_property(self, "state", states.walk, 0)
	await tween.finished
	sleep_finished.emit()


func progress_npcs() -> void:
	for npc in get_tree().get_nodes_in_group("overworld npcs"):
		if npc.state == npc.states.battle:
			continue
		var target_pos = (npc.global_position + npc.navigation_agent.get_final_position()) / 2
		target_pos.y = Globals.get_heightmap_position(target_pos)
		npc.global_position = target_pos
	for npc in get_tree().get_nodes_in_group("enemies"):
		if npc.state == npc.states.walk:
			var target_pos = (npc.global_position + npc.navigation_agent.get_final_position()) / 2
			target_pos.y = Globals.get_heightmap_position(target_pos)
			npc.global_position = target_pos


func add_skill_point() -> void:
	skill_points += 1
	if Globals.survival_ui.skills_menu.visible:
		Globals.survival_ui.skills_menu.setup()


func _on_gun_changed():
	gun = inventory.equipment_kit.equipment[gun_index]


func _on_scene_changed():
	#var scene_name = get_tree().current_scene.name
	#if scene_name == "Overworld"  or scene_name == "MainMenu":
		#reset_stats()
	state = states.walk


func _on_scene_leaving():
	if Globals.player:
		var new_hp = Globals.player.hitbox.hp
		hp = new_hp


func _on_skill_changed(skill_name: String) -> void:
	if skill_name == "strength":
		inventory.space_modifier = int(skills.strength)


func _on_ally_death(npc_data: NpcData, npc: Npc) -> void:
	allies.erase(npc_data)
	ally_npcs.erase(npc)


func save() -> Dictionary:
	hp = Globals.player.hitbox.hp
	return {
		"hp": hp,
		"ammo": ammo,
		"sleep" : sleep,
		"hunger" : hunger,
		"thirst" : thirst,
		"player_name" : player_name,
		"quests" : quests,
		"inventory" : inventory,
		"skills" : skills,
		"skill_points" : skill_points,
		"saved_style" : player_style,
		"allies" : allies,
		"save_guns" : guns,
		"arena_level" : arena_level,
		"shooting_level" : shooting_level,
	}


func _on_load():
	Globals.player.hitbox.hp = hp
	player_style.skin_colors = saved_style.skin_colors
	player_style.hair_colors = saved_style.hair_colors
	player_style.hair_styles = saved_style.hair_styles
	player_style.faces = saved_style.faces
	player_style.shirts = saved_style.shirts
	player_style.pants_colors = saved_style.pants_colors
	player_style.shoe_colors = saved_style.shoe_colors
	Globals.ui.player_model.style_data = player_style
	if save_guns.size() > 0:
		var gun_array = guns
		for i in save_guns.size():
			gun_array[i].gun_stats = save_guns[i].gun_stats
