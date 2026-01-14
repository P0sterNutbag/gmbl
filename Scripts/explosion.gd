extends Area3D

var damage: float = 3.0
var force: float = 1000
var collision_lifetime: float = 0
var damaged_objects: Array
const DUST = preload("uid://bxwa7hpni4yxi")
@onready var explosion: GPUParticles3D = $Explosion
#@onready var area_3d: Area3D = $Area3D


func _ready() -> void:
	explosion.emitting = true
	for i in 10:
		var inst = DUST.instantiate()
		get_tree().current_scene.add_child(inst)
		inst.global_position = global_position + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
		inst.emitting = true
#
#
func _process(delta: float) -> void:
	collision_lifetime += delta
	if collision_lifetime > 0.1:
		monitoring = false
		monitorable = false


func _on_area_3d_area_entered(area: Area3D) -> void:
	if damaged_objects.has(area):
		return
	if area is HealthComponent:
		area.damage(damage, area.global_position + Vector3.UP, (area.global_position - global_position).normalized())
	elif area.is_in_group("trap"):
		area.get_parent().trigger()
	damaged_objects.append(area)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if damaged_objects.has(body):
		return
	if body is RigidBody3D:
		var vector = (body.global_position - global_position).normalized() * force
		body.apply_force(vector)
	damaged_objects.append(body)


func _on_explosion_finished() -> void:
	queue_free()
