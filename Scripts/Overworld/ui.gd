extends CanvasLayer

@onready var location_card: Control = $LocationCard


func _enter_tree() -> void:
	Globals.ui = self


func show_location_info(encounter: Node3D) -> void:
	location_card.show()
	location_card.target = encounter
	if encounter.show_title:
		location_card.title_value = encounter.title
	else:
		location_card.title_value = "???"
	if encounter.show_faction:
		location_card.faction_value = encounter.faction
	else:
		location_card.faction_value = "???"
	if encounter.show_difficulty:
		location_card.difficulty_value = encounter.difficulty
	else:
		location_card.difficulty_value = "???"
	if encounter.show_resources:
		location_card.resources_value = encounter.resources
	else:
		location_card.resources_value = "???"
	location_card.set_process(true)


func hide_location_info() -> void:
	location_card.hide()
	location_card.set_process(false)
