extends Node

@export var starting_inventory: Inventory
@export var allies: Array[PackedScene]
@export var stats: CharacterStats
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
var flashlight_on: bool
var inventory: Inventory = Inventory.new()
var quests: Array[Quest]
var gun: EquipmentGun
var gun_index := 0
var sleep: float
var hunger: float
var thirst: float
var soberness: float = 1.0
var max_sleep: float
var max_hunger: float
var max_thirst: float
var max_soberness: float = 1.0
var sleep_decrease_rate := 0.2
var hunger_decrease_rate := 0.6
var thirst_decrease_rate := 0.8
@onready var guns: Array[Item]:
	get(): 
		return inventory.items.filter(func(i): return i is EquipmentGun and i.gun_stats.ammo > 0)
signal gun_changed


func _ready() -> void:
	reset_stats()
	SceneManager.scene_changed.connect(_on_scene_changed)
	SceneManager.scene_leaving.connect(_on_scene_leaving)
	SaveController.load.connect(_on_load)
	gun_changed.connect(_on_gun_changed)
	await get_tree().process_frame
	max_sleep = DayNightCycle.day_length / sleep_decrease_rate
	max_hunger = DayNightCycle.day_length / hunger_decrease_rate
	max_thirst = DayNightCycle.day_length / thirst_decrease_rate
	sleep = max_sleep
	hunger = max_hunger
	thirst = max_thirst
	faction = FactionManager.factions.player
	inventory.space += stats.strength
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
		Globals.player.hitbox.hp -= 0.025 * delta
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
	#inventory.money = ProgressManager.progress_data.starting_money
	#equipped_guns[guns[0].slot] = guns[0]
	#for i in equipped_guns:
		#if i:
			#i.gun_stats.reset()
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


func give_up() -> void:
	PlayerStats.reset_stats()
	SaveController.delete_save_data()
	Globals.overworld.queue_free()


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


func go_to_sleep():
	if get_tree().current_scene != Globals.overworld:
		return
	UiController.close_interface(Globals.survival_ui.menu_holder)
	change_state(states.pause)
	var tween = create_tween()
	tween.tween_callback(SceneManager.animation_player.play.bind("fade_in"))
	tween.tween_callback(DayNightCycle.skip_to_time.bind(1.5))
	tween.tween_callback(SceneManager.animation_player.play.bind("fade_out")).set_delay(2)
	tween.tween_callback(kill_all_npcs)
	tween.tween_property(self, "sleep", max_sleep, 0)
	tween.tween_property(self, "soberness", max_soberness, 0)
	tween.tween_property(Globals.player.hitbox, "hp", Globals.player.hitbox.hp + 0.5, 0)
	tween.tween_property(self, "state", states.walk, 0)



func kill_all_npcs() -> void:
	BattleManager.delete_all_battles()
	for npc in get_tree().get_nodes_in_group("overworld npcs"):
		npc.queue_free()


func _on_gun_changed():
	gun = inventory.equipment_kit.equipment[gun_index]


func _on_scene_changed():
	state = states.walk


func _on_scene_leaving():
	if Globals.player:
		var new_hp = Globals.player.hitbox.hp
		hp = new_hp


func save() -> Dictionary:
	hp = Globals.player.hitbox.hp
	#ResourceSaver.save(inventory, "user://inventory.res")
	#var save_quests = ArraySaver.new()
	#save_quests.array.append_array(quests)
	#ResourceSaver.save(save_quests, "user://quests.res")
	return {
		"hp": hp,
		"ammo": ammo,
		"sleep" : sleep,
		"hunger" : hunger,
		"thirst" : thirst,
		"player_name" : player_name,
		"quests" : quests,
		"inventory" : inventory,
		"stats" : stats
	}


func _on_load():
	#inventory = ResourceLoader.load("user://inventory.res")
	#var save_quests = ResourceLoader.load("user://quests.res")
	#if save_quests:
		#quests.clear()
		#quests.append_array(save_quests.array)
	Globals.player.hitbox.hp = hp
