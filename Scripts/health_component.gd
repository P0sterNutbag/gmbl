extends Area3D
class_name HealthComponent

@export var hp: float
@export var hp_bar: Control
@onready var max_hp: float = hp
signal damaged
signal death


func _ready() -> void:
	death.connect(get_parent()._on_death)
	damaged.connect(get_parent()._on_damaged)


func damage(dmg: float) -> void:
	hp -= dmg
	if hp_bar:
		hp_bar.value = hp / max_hp
	damaged.emit()
	if hp <= 0:
		death.emit()
