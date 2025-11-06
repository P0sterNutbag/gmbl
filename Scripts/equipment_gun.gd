extends Equipment
class_name EquipmentGun

@export var gun_stats: GunStats = GunStats.new()
@export var slot: int
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
	for gun in PlayerStats.guns:
		if gun != self and gun.slot == slot:
			gun.equipped = false
	if equipped:
		PlayerStats.equipped_guns[slot] = self
		if PlayerStats.gun_index == slot:
			Globals.player.change_gun(self)
	else:
		PlayerStats.equipped_guns[slot] = null
		if PlayerStats.gun_index == slot:
			Globals.player.unequip_gun()
