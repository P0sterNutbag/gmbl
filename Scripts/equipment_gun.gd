extends Equipment
class_name EquipmentGun

@export var gun_stats: GunStats# = GunStats.new()
@export var gun_object: PackedScene
var ammo: 
	get(): return gun_stats.ammo
var condition: 
	get(): return snappedf(gun_stats.condition, 0.01)
class EquipmentStat:
	var name: String
	var variable_name: String
	var max_value: Variant
	func _init(_name: String, _variable_name: String, _max_value: int = 0, _use_color: bool = false):
		name = _name
		variable_name = _variable_name
		max_value = _max_value
var stats := [
	EquipmentStat.new("AMMO", "ammo"),
	EquipmentStat.new("CND", "condition", 100, true),
]


func equip() -> void:
	super.equip()
	if equipped:
		PlayerStats.gun_index = slot
	PlayerStats.gun_changed.emit()


func unequip() -> void:
	super.unequip()
	PlayerStats.gun_changed.emit()


func get_modified_price() -> int:
	if gun_stats:
		return round(price * (gun_stats.condition / 100))
	else:
		return price
