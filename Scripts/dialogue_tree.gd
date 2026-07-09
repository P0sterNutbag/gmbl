extends Resource
class_name DialogueTree

@export var bubbles: Array[DialogueBase]
@export var npc_style: NpcStyle = preload("res://Resources/NpcStyles/npc_styles.tres")
@export var npc_name: String = "NPC"
@export var camera_angle: float
