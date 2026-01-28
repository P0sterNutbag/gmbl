extends Area3D
class_name HealthComponent

@export var hp: float:
	set(value):
		hp = value #clamp(value, 0, max_hp)
		if max_hp > 0 and hp > max_hp:
			hp = max_hp
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


func damage(dmg: float, hit_position: Vector3 = Vector3.ZERO, hit_direction: Vector3 = Vector3.ZERO, shooter: Node3D = null, allow_damage_mod: bool = true, blood: bool = true, play_audio: bool = true) -> void:
	damaged.emit(hit_position, hit_direction, shooter)
	if is_dead:
		return
	if !allow_damage_mod:
		damage_modifier = 1
	hp -= dmg * damage_modifier
	if audio_stream_player and play_audio:
		audio_stream_player.play()
	if hp <= 0:
		death.emit()
		is_dead = true
		var all_children := []
		all_children.append_array(get_children())
		for inst in otherHitboxes:
			all_children.append_array(inst.get_children())
		for child in all_children:
			if child is CollisionShape3D:
				child.set_deferred("disabled", true)
	if !blood_on_hit or !blood:
		return
	var inst = blood_spatter.instantiate()
	var spawn_pos = get_parent().global_position + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
	inst.set_deferred("global_position", spawn_pos)
	inst.rotate_y(deg_to_rad(randf_range(-180, 180)))
	get_tree().current_scene.add_child(inst)


func revive() -> void:
	await get_tree().create_timer(5).timeout
	is_dead = false
	var all_children := []
	all_children.append_array(get_children())
	for inst in otherHitboxes:
		all_children.append_array(inst.get_children())
	for child in all_children:
		if child is CollisionShape3D:
			child.set_deferred("disabled", false)
