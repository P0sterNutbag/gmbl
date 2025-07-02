extends Node

enum states {walk, pause, dead}
var state = states.walk
var money: int = 0
var hp: int = 5:
	set(value):
		hp = value
		Globals.player.hitbox.hp = value
	get():
		if "hitbox" in Globals.player:
			return Globals.player.hitbox.hp
		else:
			return 5
var ammo: int:
	set(value):
		ammo = value
		gun.gun_stats.ammo = value
	get():
		return gun.gun_stats.ammo
var items: Array[Item]
var guns: Array[Item]:
	get(): return items.filter(func(i): return i is EquipmentGun)
var gun: EquipmentGun


func _enter_tree() -> void:
	state = states.walk
	#items.append(load("res://Resources/Items/Ammo/rifle_ammo.tres"))


func _ready() -> void:
	gun = load("res://Resources/Items/Guns/ak47.tres").duplicate()
	gun.equipped = true
	items.append(gun)


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


#func set_guns() -> void:
	#guns.clear()
	#var gun_items = items.filter(func(item): return item is GunItem)
	#for item in gun_items:
		#guns.append(item.gun_name)
