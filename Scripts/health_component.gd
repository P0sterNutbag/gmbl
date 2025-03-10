extends Area3D
class_name HealthComponent

@export var hp: float
signal death


func _ready() -> void:
	death.connect(get_parent()._on_death)


func damage(dmg: float) -> void:
	hp -= dmg
	if hp <= 0:
		death.emit()
