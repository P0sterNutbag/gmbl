extends Weapon

@export var damage: float = 1.0:
	get():
		if uses_input:
			return damage + PlayerStats.skills.strength * 0.2 
		else:
			return damage
@onready var hitbox: Area3D = $MeshInstance3D/Hitbox
var can_damage: bool
const BLOODSPATTER = preload("uid://cqvgbxo1nn47e")


func use(shot_owner: Node3D = null):
	if super.use(shot_owner):
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
	body.health_component.damage(damage, global_position, rotation, Globals.player)
	can_damage = false
	hitbox.set_deferred("monitoring", false)


func _on_hitbox_area_entered(area: Area3D) -> void:
	area.owner.model.get_scalped()
	var inst = BLOODSPATTER.instantiate()
	area.add_child(inst)
	#inst.global_position = area.global_position
