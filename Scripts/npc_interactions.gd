extends InteractableObject

@export var health_component: HealthComponent
@onready var scalp_pos: Node3D = $"../EnemyModel/PersonAnimated/Armature/Skeleton3D/HeadAttachment/Scalp"
const BLOODSPATTER = preload("uid://cqvgbxo1nn47e")


func _ready() -> void:
	actions = ["Loot", "Scalp"]


func interact() -> void:
	if health_component and !health_component.is_dead:
		return
	if index == 0:
		Globals.survival_ui.loot(health_component.get_parent().inventory)
	if index == 1:
		if !PlayerStats.inventory.find_item("knife"):
			Globals.survival_ui.create_notification("Missing knife")
			return
		var enemy = health_component.get_parent()
		var scalp = FactionManager.faction_data[enemy.faction].scalp.duplicate()
		if !PlayerStats.inventory.add_item(scalp, 1, true):
			return
		enemy.model.get_scalped()
		var inst = BLOODSPATTER.instantiate()
		get_parent().add_child(inst)
		inst.global_position = scalp_pos.global_position
		health_component.audio_stream_player.play()
		#Globals.survival_ui.create_notification(scalp.title + "added to inventory")
		actions.remove_at(1)
		index = 0
