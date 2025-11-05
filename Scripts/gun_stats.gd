extends Resource
class_name GunStats

@export var ammo: int = 8
@export var condition: float = 100.0
var max_ammo = ammo
var max_condition = condition


func reset() -> void:
	ammo = max_ammo
	condition = max_condition
