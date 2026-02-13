extends Weapon

@export var grenade: PackedScene# = preload("uid://bonl158sskj1q")
var can_damage: bool


func use(shot_owner: Node3D):
	if super.use(shot_owner):
		if anim_player and !anim_player.is_playing():
			anim_player.play("throw")
			can_damage = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "throw":
		can_use = true
