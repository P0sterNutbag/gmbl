extends Node3D

@onready var area_3d: Area3D = $Area3D
@onready var timer: Timer = $Timer
@onready var collision_shape: CollisionShape3D = $Area3D/CollisionShape3D
var event_creator: Node


func _ready() -> void:
	Globals.noise_controller = self
	area_3d.monitoring = false


func create_noise_event(event_position: Vector3, creator: Node, event_radius: float = 10):
	area_3d.global_position = event_position
	event_creator = creator
	collision_shape.shape.radius = event_radius
	area_3d.monitoring = true
	timer.start()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("on_noise_heard"):
		body.on_noise_heard(area_3d.global_position, event_creator)


func _on_timer_timeout() -> void:
	area_3d.monitoring = false
