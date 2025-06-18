extends Equipment
class_name EquipmentGun

@export var gun_stats: GunStats = GunStats.new()


func equip() -> void:
	super.equip()
	if equipped:
		equipped = false
		return
	for gun in PlayerStats.guns:
		gun.equipped = false
	equipped = true
	Globals.player.change_gun(self)
