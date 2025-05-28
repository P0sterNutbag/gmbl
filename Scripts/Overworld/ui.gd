extends CanvasLayer

@onready var encounter_info: Control = $EncounterInfo
@onready var distance: Label = $EncounterInfo/Label2

func _enter_tree() -> void:
	Globals.ui = self


func show_encounter_info(encounter: Node3D) -> void:
	encounter_info.show()
	distance.text = "Distance: " + str(snappedf(Globals.player.global_position.distance_to(encounter.global_position), 0.01))


func hide_encounter_info() -> void:
	encounter_info.hide()
