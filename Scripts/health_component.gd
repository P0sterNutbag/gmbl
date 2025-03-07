extends Area3D
class_name HealthComponent

@export var hp: float


func damage(dmg: float) -> void:
	hp -= dmg
	if hp <= 0:
		die()


func die() -> void:
	get_parent().queue_free()
