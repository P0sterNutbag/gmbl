extends Weapon

@export var damage: float = 1.5
@onready var hitbox: Area3D = $MeshInstance3D/Hitbox


func use():
	super.use()
	hitbox.monitoring = true
	if anim_player:
		anim_player.play("stab")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "stab":
		can_use = true
		hitbox.monitoring = false


func _on_area_3d_body_entered(body: Node3D) -> void:
	body.health_component.damage(damage)
	hitbox.set_deferred("monitoring", false)
