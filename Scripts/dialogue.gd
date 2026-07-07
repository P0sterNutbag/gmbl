extends Resource
class_name Dialogue

enum speakers {player, npc}
@export_multiline var lines: Array[String]
@export var speaker: speakers
