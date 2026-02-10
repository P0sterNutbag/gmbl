extends PanelContainer

@onready var grid_container: GridContainer = $MarginContainer/GridContainer


func set_relations() -> void:
	for child in grid_container.get_children():
		if "faction_vertical" in child:
			var score = FactionManager.get_faction_relation(child.faction_vertical, child.faction_horizontal)
			child.text = str(score)
			var color = Color(1.0, 1.0, 0.0, 1.0)
			if score < 0:
				color = Color(1.0, 0.0, 0.0, 1.0)
			elif score > 0:
				color = Color(0.0, 1.0, 0.0, 1.0)
			child.add_theme_color_override("font_color", color)


func _on_visibility_changed() -> void:
	if visible:
		set_relations()
