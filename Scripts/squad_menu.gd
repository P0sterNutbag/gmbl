extends Control

const ALLY = preload("uid://cikxsk48swg6f")
@onready var squad_ui: PanelContainer = $PanelContainer


func populate_squad() -> void:
	squad_ui.item_container.delete_children()
	for ally in PlayerStats.allies:
		var ally_button = squad_ui.item_container.add_button(ALLY)
		ally_button.npc_data = ally
	squad_ui.population = PlayerStats.allies.size()
	squad_ui.capacity = PlayerStats.max_allies


func _on_visibility_changed() -> void:
	if visible:
		populate_squad()
