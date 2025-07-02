extends Node3D

var current_encounter: Node3D
@onready var npc_portrait_model: Node3D = $ShopkeeperPortrait/EnemyModel2


func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	if current_encounter and current_encounter.population <= 0 and current_encounter.get_parent().has_method("die"):
		current_encounter.get_parent().die()


func _ready() -> void:
	Globals.overworld = self
