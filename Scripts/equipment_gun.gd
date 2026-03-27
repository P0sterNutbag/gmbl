extends Equipment
class_name EquipmentGun

@export var gun_stats: GunStats# = GunStats.new()
@export var gun_object: PackedScene
var ammo: 
	get(): return gun_stats.ammo
var condition: 
	get(): return snappedf(gun_stats.condition, 0.01)
var stats := {
	"AMMO": "ammo",
	"CND": "condition"
}


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
		return round(price * (gun_stats.condition / 125))
	else:
		return price
