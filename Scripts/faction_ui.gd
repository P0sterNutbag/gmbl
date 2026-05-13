extends PanelContainer

@onready var grid_container: GridContainer = $MarginContainer/GridContainer
const UiColorChanger = preload("uid://b5ok34ueyf7g5")


func set_relations() -> void:
	for child in grid_container.get_children():
		if "faction_vertical" in child:
			var score = FactionManager.get_faction_relation(child.faction_vertical, child.faction_horizontal)
			child.text = str(score)
			var color: Color = child.get_theme_color("font_color")
			var new_color = color
			if score < 0:
				new_color = color.darkened(0.15)
			elif score > 0:
				new_color = color.lightened(0.1)
			child.add_theme_color_override("font_color", new_color)


func _on_visibility_changed() -> void:
	if visible:
		set_relations()
