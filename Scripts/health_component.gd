extends Area3D
class_name HealthComponent

@export var hp: float:
	set(value):
		if value > hp and hp != 0:
			hp = value
			hp = clamp(hp, 0, max_hp - unhealable_hp)
		else:
			hp = value
		if hp_bar:
			if hp_bar is ProgressBar:
				hp_bar.value = hp / max_hp
			elif hp_bar is Label:
				hp_bar.text = "HP:" + str(int((hp / max_hp) * 100))
@export var hp_bar: Control
@export var hp_bar2: Control
@export var otherHitboxes: Array[HealthComponent]
@onready var max_hp: float = hp
var unhealable_hp: int = 0:
	set(value):
		unhealable_hp += value
		unhealable_hp = clamp(unhealable_hp, 0, max_hp)
		if hp_bar2:
			hp_bar2.value = unhealable_hp / max_hp
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
	if randf() < 0.2:
		unhealable_hp += 1
	if hp <= 0:
		death.emit()
		is_dead = true
		for inst in otherHitboxes:
			inst.queue_free()
		for child in get_children():
			child.disabled = true
