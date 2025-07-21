extends Equipment
class_name EquipmentGun

@export var gun_stats: GunStats = GunStats.new()
var ammo: 
	get(): return gun_stats.ammo
var condition: 
	get(): return gun_stats.condition
var stats := {
	"AMMO": "ammo",
	"CND": "condition"
}


func equip() -> void:
	super.equip()
	for gun in PlayerStats.guns:
		if gun != self:
			gun.equipped = false
	equipped = !equipped
	if equipped:
		Globals.player.change_gun(self)
	else:
		Globals.player.unequip_gun()
