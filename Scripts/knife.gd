extends Weapon

@export var damage: float = 1.0:
	get():
		if uses_input:
			return damage + PlayerStats.skills.strength * 0.2 
		else:
			return damage
@onready var hitbox: Area3D = $MeshInstance3D/Hitbox
@onready var raycast: RayCast3D = $RayCast3D
var can_damage: bool
const BLOODSPATTER = preload("uid://cqvgbxo1nn47e")
const HITMARKER = preload("uid://br3gfklclueb")


func use(shot_owner: Node3D = null):
	if super.use(shot_owner):
		if anim_player and !anim_player.is_playing():
			anim_player.play("stab")
			can_damage = true
			hitbox.monitoring = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "stab":
		can_use = true
		hitbox.monitoring = false


func _on_area_3d_body_entered(body: Node3D) -> void:
	if !can_damage:
		return
	if "health_component" in body:
		body.health_component.damage(damage, global_position, rotation, Globals.player)
	if body is RigidBody3D:
		body.apply_impulse(-Globals.player.global_transform.basis.z.normalized() * 3)
	can_damage = false
	hitbox.set_deferred("monitoring", false)
	# create hitmark
	if body.get_parent() is CharacterBody3D:
		return
	var inst = HITMARKER.instantiate()
	get_tree().current_scene.add_child(inst)
	var remote_transform = RemoteTransform3D.new()
	remote_transform.remote_path = inst.get_path()
	remote_transform.update_scale = false
	body.add_child(remote_transform)
	remote_transform.global_position = raycast.get_collision_point()
	remote_transform.look_at(remote_transform.global_position + raycast.get_collision_normal(), Vector3.FORWARD)
	inst.tree_exited.connect(remote_transform.queue_free)


#func _on_hitbox_area_entered(area: Area3D) -> void:
	#area.owner.model.get_scalped()
	#var inst = BLOODSPATTER.instantiate()
	#area.add_child(inst)
	#area.owner.health_component.audio_stream_player.play()
	#area.queue_free()
	#var scalp = FactionManager.faction_data[area.owner.faction].scalp.duplicate()
	#PlayerStats.inventory.add_item(scalp)
	#Globals.survival_ui.create_notification(scalp.title + "added to inventory")
	##inst.global_position = area.global_position


func _on_hitbox_area_entered(area: Area3D) -> void:
	if !can_damage or area is not HealthComponent:
		return
	area.damage(damage, global_position, rotation, Globals.player)
	can_damage = false
	hitbox.set_deferred("monitoring", false)
