extends Node
class_name InteractableObject

@export var tooltip_text: String


func interact():
	if PlayerStats.gun and PlayerStats.inventory.get_item_amount(Globals.player.gun.ammo_item) == 0:
		PlayerStats.inventory.add_item(Globals.player.gun.ammo_item)
		#PlayerStats.reload_gun()
		#PlayerStats.gun.gun_stats.ammo = PlayerStats.gun.gun_stats.max_ammo
		#Globals.player.gun.gun_stats.ammo = PlayerStats.gun.gun_stats.max_ammo
