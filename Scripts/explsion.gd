extends Area3D

var dmg = 3


func _on_area_entered(area: Area3D) -> void:
	area.damage(dmg)
