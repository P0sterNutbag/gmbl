extends Area3D
class_name HealthComponent

@export var hp: float:
	set(value):
		if value > hp and hp != 0:
			hp = value
		else:
			hp = value
		if hp_bar:
			if hp_bar is ProgressBar:
				hp_bar.value = hp / max_hp
			elif hp_bar is Label:
				hp_bar.text = "HP:" + str(int((hp / max_hp) * 100))
@export var hp_bar: Control
@export var otherHitboxes: Array[HealthComponent]
@export var blood_on_hit: bool = true
@onready var max_hp: float = hp
var audio_stream_player: AudioStreamPlayer3D
var damage_modifier: float = 1.0
var is_dead: bool
var blood_spatter: PackedScene = preload("res://Scenes/Particles/bloodspatter_ground.tscn")
signal damaged(hit_position: Vector3, hit_direction: Vector3)
signal death


func _ready() -> void:
	if get_parent().has_method("_on_death"):
		death.connect(get_parent()._on_death)
	if get_parent().has_method("_on_damaged"):
		damaged.connect(get_parent()._on_damaged)
	if get_node_or_null("AudioStreamPlayer3D"):
		audio_stream_player = $AudioStreamPlayer3D


func damage(dmg: float, hit_position: Vector3 = Vector3.ZERO, hit_direction: Vector3 = Vector3.ZERO) -> void:
	damaged.emit(hit_position, hit_direction)
	if is_dead:
		return
	hp -= dmg * damage_modifier
	if audio_stream_player:
		audio_stream_player.play()
	if hp <= 0:
		death.emit()
		is_dead = true
		for inst in otherHitboxes:
			inst.queue_free()
		for child in get_children():
			if child is CollisionShape3D:
				child.set_deferred("disabled", true)
	if !blood_on_hit:
		return
	var inst = blood_spatter.instantiate()
	var spawn_pos = get_parent().global_position + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
	inst.set_deferred("global_position", spawn_pos)
	inst.rotate_y(deg_to_rad(randf_range(-180, 180)))
	get_tree().current_scene.add_child(inst)
