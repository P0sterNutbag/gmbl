extends Node

enum states {walk, pause, dead}
var state = states.walk
@export var money: int = 0
var hp: int = 5:
	set(value):
		hp = value
		if Globals.player and "hitbox" in Globals.player:
			Globals.player.hitbox.hp = value
	get():
		if Globals.player and "hitbox" in Globals.player:
			return Globals.player.hitbox.hp
		else:
			return 5
var max_hp := 5
var ammo: int:
	set(value):
		ammo = value
		gun.gun_stats.ammo = value
	get():
		if gun:
			return gun.gun_stats.ammo
		else:
			return 0
var items:
	get():
		return inventory.items
@export var inventory: Inventory
@export var quests: Array[Quest]
@onready var guns: Array[Item]:
	get(): return items.filter(func(i): return i is EquipmentGun)
var gun: EquipmentGun
@onready var equipped_guns: Array[EquipmentGun] = [guns[0], null]
var gun_index := 0
var sleep := 100.0:
	set(value):
		sleep = clamp(value, 0, max_sleep)
var hunger := 100.0:
	set(value):
		hunger = clamp(value, 0, max_hunger)
var thirst := 100.0:
	set(value):
		thirst = clamp(value, 0, max_thirst)
var max_sleep := 100.0
var max_hunger := 100.0
var max_thirst = 100.0
var sleep_decrease_rate := 0.5
var hunger_decrease_rate := 0.75
var thirst_decrease_rate := 1.0


func _enter_tree() -> void:
	state = states.walk


func _ready() -> void:
	if items.size() > 0 and items[0] is EquipmentGun:
		gun = items[0]
		gun.equipped = true


func _process(delta: float) -> void:
	sleep -= delta * sleep_decrease_rate
	hunger -= delta * hunger_decrease_rate
	thirst -= delta * thirst_decrease_rate
	if !guns.has(gun):
		gun = null
	for i in equipped_guns.size() - 1:
		if !guns.has(equipped_guns[i]):
			equipped_guns[i] = null


func _physics_process(delta):
	# state machine
	if !Globals.player or !get_tree().current_scene:
		return
	if Globals.player.process_mode == PROCESS_MODE_DISABLED or get_tree().current_scene.process_mode == PROCESS_MODE_DISABLED:
		return
	if Globals.player.state_functions.has(PlayerStats.state):
		Globals.player.state_functions[PlayerStats.state].call(delta)


func change_state(new_state):
	if Globals.player.exit_functions.has(PlayerStats.state):
		await Globals.player.exit_functions[PlayerStats.state].call()
	PlayerStats.state = new_state
	if Globals.player.enter_functions.has(PlayerStats.state):
		await Globals.player.enter_functions[PlayerStats.state].call()


func get_item_amount(item_name: String) -> int:
	if items.size() <= 0:
		return 0
	return items.filter(func(i): return i != null and i.resource_name == item_name).size()


func save() -> Dictionary:
	return {
		"money": money,
		"hp": hp,
		"ammo": ammo,
		"items" : items
	}


func unquip_current_item():
	for item in items:
		if item is Equipment:
			item.equipped = false


func delete_current_equip():
	for item in items:
		if item is Equipment and item.equipped:
			items.erase(item)


func go_to_sleep():
	Globals.ui.inventory_holder.hide()
	change_state(states.pause)
	var tween = create_tween()
	tween.tween_callback(SceneManager.animation_player.play.bind("fade_in"))
	tween.tween_callback(SceneManager.animation_player.play.bind("fade_out")).set_delay(2)
	tween.tween_property(self, "sleep", max_sleep, 0)
	tween.tween_property(self, "state", states.walk, 0)
	
