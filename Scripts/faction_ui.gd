extends PanelContainer

@onready var grid_container: GridContainer = $MarginContainer/GridContainer
const UiColorChanger = preload("uid://b5ok34ueyf7g5")


func set_relations() -> void:
	for child in grid_container.get_children():
		if "faction_vertical" in child:
			var score = FactionManager.get_faction_relation(child.faction_vertical, child.faction_horizontal)
			child.text = str(score)
			var color = child.get_theme_color("font_color")
			if score < 0:
				color = Color(1.0, 0.0, 0.0, 1.0)
			elif score > 0:
				color = Color(0.0, 1.0, 0.0, 1.0)
			child.add_theme_color_override("font_color", color)


func _on_visibility_changed() -> void:
	if visible:
		set_relations()
