extends Node3D

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var rigid_body_3d: RigidBody3D = $RigidBody3D
@onready var collision_shape_3d: CollisionShape3D = $RigidBody3D/CollisionShape3D


func _on_health_component_death() -> void:
	rigid_body_3d.visible = false
	collision_shape_3d.disabled = true
	gpu_particles_3d.emitting = true
	audio_stream_player_3d.play()



func _on_audio_stream_player_3d_finished() -> void:
	queue_free()
