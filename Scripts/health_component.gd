extends Area3D
class_name HealthComponent

@export var hp: float:
	set(value):
		hp = value
		if hp_bar:
			if hp_bar is ProgressBar:
				hp_bar.value = hp / max_hp
			elif hp_bar is Label:
				hp_bar.text = "HP:" + str(int((hp / max_hp) * 100))
@export var hp_bar: Control
@export var otherHitboxes: Array[HealthComponent]
@onready var max_hp: float = hp
var is_dead: bool
signal damaged(hit_position: Vector3, hit_direction: Vector3)
signal death


func _ready() -> void:
	death.connect(get_parent()._on_death)
	damaged.connect(get_parent()._on_damaged)


func damage(dmg: float, hit_position: Vector3, hit_direction: Vector3) -> void:
	damaged.emit(hit_position, hit_direction)
	if is_dead:
		return
	hp -= dmg
	if hp <= 0:
		death.emit()
		is_dead = true
		for inst in otherHitboxes:
			inst.queue_free()
		queue_free()
