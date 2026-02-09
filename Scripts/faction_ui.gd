extends PanelContainer

@onready var grid_container: GridContainer = $MarginContainer/GridContainer


func set_relations() -> void:
	for child in grid_container.get_children():
		if "faction_vertical" in child:
			if child.faction_vertical != child.faction_horizontal:
				child.text = str(FactionManager.get_faction_relation(child.faction_vertical, child.faction_horizontal))
			else:
				child.text = ""


func _on_visibility_changed() -> void:
	if visible:
		set_relations()
