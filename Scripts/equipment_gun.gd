extends Equipment
class_name EquipmentGun

@export var gun_stats: GunStats = GunStats.new()
@export var gun_object: PackedScene
#@export var slot: int
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
		if PlayerStats.gun_index == slot or !PlayerStats.gun:
			Globals.player.change_gun(self)
	else:
		if PlayerStats.gun_index == slot:
			Globals.player.unequip_gun()


func get_modified_price() -> int:
	return round(price * gun_stats.condition / 100)
