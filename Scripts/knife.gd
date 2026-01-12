extends Weapon

@export var damage: float = 1.5
@onready var hitbox: Area3D = $MeshInstance3D/Hitbox
var can_damage: bool


func use():
	if super.use():
		if anim_player and !anim_player.is_playing():
			anim_player.play("stab")
			can_damage = true
			hitbox.monitoring = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "stab":
		can_use = true


func _on_area_3d_body_entered(body: Node3D) -> void:
	if !can_damage:
		return
	body.health_component.damage(damage)
	can_damage = false
	hitbox.set_deferred("monitoring", false)
