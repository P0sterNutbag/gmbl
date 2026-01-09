extends Node

enum states {walk, pause, dead}
var state = states.walk
var hp: float = 8:
	set(value):
		hp = value
		if Globals.player and "hitbox" in Globals.player and Globals.player.hitbox:
			Globals.player.hitbox.hp = value
	get():
		return Globals.player.hitbox.hp
var max_hp := 8
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
@export var starting_inventory: Inventory
var inventory: Inventory = Inventory.new()
var quests: Array[Quest]
@onready var guns: Array[Item]:
	get(): 
		return inventory.items.filter(func(i): return i is EquipmentGun and i.gun_stats.ammo > 0)
var gun: EquipmentGun
var gun_index := 0
var sleep := 1.0
var hunger := 1.0
var thirst := 1.0
var max_sleep := 1.0
var max_hunger := 1.0
var max_thirst = 1.0
var sleep_decrease_rate = 5
var hunger_decrease_rate = 6
var thirst_decrease_rate = 4
signal gun_changed


func _ready() -> void:
	reset_stats()
	SceneManager.scene_changed.connect(_on_scene_changed)
	SaveController.load.connect(_on_load)
	gun_changed.connect(_on_gun_changed)
	await get_tree().process_frame
	sleep_decrease_rate = DayNightCycle.time_speed / sleep_decrease_rate
	hunger_decrease_rate = DayNightCycle.time_speed / hunger_decrease_rate
	thirst_decrease_rate = DayNightCycle.time_speed / thirst_decrease_rate


func _process(delta: float) -> void:
	# survival stats
	sleep = clamp(sleep - delta * sleep_decrease_rate, 0, max_sleep)
	hunger = clamp(hunger - delta * hunger_decrease_rate, 0, max_hunger)
	thirst = clamp(thirst - delta * thirst_decrease_rate, 0, max_thirst)
	if hunger <= 0 or thirst <= 0:
		Globals.player.hitbox.damage(0.25 * delta, Vector3.ZERO, Vector3.ZERO, false, false, false)
	# gun management
	#if !guns.has(gun):
		#gun = null
	#for i in equipped_guns.size() - 1:
		#if !guns.has(equipped_guns[i]):
			#equipped_guns[i] = null


func _physics_process(delta):
	# state machine
	if !Globals.player or !get_tree().current_scene:
		return
	if Globals.player.process_mode == PROCESS_MODE_DISABLED or get_tree().current_scene.process_mode == PROCESS_MODE_DISABLED:
		return
	if Globals.player.state_functions.has(PlayerStats.state):
		Globals.player.state_functions[PlayerStats.state].call(delta)


func reset_stats() -> void:
	inventory = starting_inventory.duplicate(true)
	inventory.money = ProgressManager.progress_data.starting_money
	inventory.equipment_kit.remove_all()
	#equipped_guns[guns[0].slot] = guns[0]
	#for i in equipped_guns:
		#if i:
			#i.gun_stats.reset()
	quests.clear()
	hp = max_hp
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


#func find_item(item_name: String) -> Resource:
	#for i in items:
		#if i != null and i.resource_name == item_name:
			#return i
	#return null


#func get_item_amount(item_name: String) -> int:
	#var item = inventory.find_item_slot(item_name).item
	#if item:
		#return item.amount
	#return 0
	#if items.size() <= 0:
		#return 0
	#return items.filter(func(i): return i != null and i.resource_name == item_name).size()


func save() -> Dictionary:
	hp = Globals.player.hitbox.hp
	ResourceSaver.save(inventory, "user://inventory.res")
	return {
		"hp": hp,
		"ammo": ammo,
		"inventory.item_slots" : inventory.item_slots
	}


func unquip_current_item():
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


func go_to_sleep():
	UiController.close_interface(Globals.survival_ui.player_inventory_holder)
	change_state(states.pause)
	var tween = create_tween()
	tween.tween_callback(SceneManager.animation_player.play.bind("fade_in"))
	tween.tween_callback(SceneManager.animation_player.play.bind("fade_out")).set_delay(2)
	tween.tween_property(self, "sleep", max_sleep, 0)
	tween.tween_property(self, "state", states.walk, 0)
	await tween.finished
	DayNightCycle.time_speed *= 0.1


func _on_gun_changed():
	gun = inventory.equipment_kit.equipment[gun_index]


func _on_scene_changed():
	state = states.walk
	if Globals.player:
		hp = Globals.player.hitbox.hp


func _on_load():
	inventory = ResourceLoader.load("user://inventory.res")
