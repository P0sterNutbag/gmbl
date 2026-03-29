extends PhysicalBone3D

@export var health_component: HealthComponent
@export var damage_modifier: float = 1.0
var interaction_object: Node3D


func _ready() -> void:
	interaction_object = owner.get_parent().get_node_or_null("Interaction")


func turn_off_simulation() -> void:
	await get_tree().create_timer(1).timeout
	if health_component and !health_component.is_dead:
		get_parent().physical_bones_stop_simulation()
