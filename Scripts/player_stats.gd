extends Node

enum states {walk, pause, dead}
var state = states.walk
var money: int = 0
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
var ammo: int:
	set(value):
		ammo = value
		gun.gun_stats.ammo = value
	get():
		if gun:
			return gun.gun_stats.ammo
		else:
			return 0
@export var items: Array[Item]
var guns: Array[Item]:
	get(): return items.filter(func(i): return i is EquipmentGun)
var gun: EquipmentGun
@export var quests: Array[Quest]


func _enter_tree() -> void:
	state = states.walk


func _ready() -> void:
	if items.size() > 0 and items[0] is EquipmentGun:
		gun = items[0]
		gun.equipped = true


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
	}


func unquip_current_item():
	for item in items:
		if item is Equipment:
			item.equipped = false


func delete_current_equip():
	for item in items:
		if item is Equipment and item.equipped:
			items.erase(item)
