extends Area3D
class_name HealthComponent

@export var hp: float:
	set(value):
		hp = value
		if hp_bar:
			hp_bar.value = hp / max_hp
@export var hp_bar: Control
@onready var max_hp: float = hp
var is_dead: bool
signal damaged
signal death


func _ready() -> void:
	death.connect(get_parent()._on_death)
	damaged.connect(get_parent()._on_damaged)


func damage(dmg: float) -> void:
	if is_dead:
		return
	hp -= dmg
	damaged.emit()
	if hp <= 0:
		death.emit()
		is_dead = true
