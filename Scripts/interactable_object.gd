extends Node
class_name InteractableObject

@export var tooltip_text: String


func interact():
	if PlayerStats.gun:
		PlayerStats.reload_gun()
		#PlayerStats.gun.gun_stats.ammo = PlayerStats.gun.gun_stats.max_ammo
		#Globals.player.gun.gun_stats.ammo = PlayerStats.gun.gun_stats.max_ammo
