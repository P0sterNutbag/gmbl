extends MenuList


const ALLY = preload("uid://cikxsk48swg6f")


func populate_squad() -> void:
	for ally in PlayerStats.allies:
		var ally_button = item_container.add_button(ALLY)
		ally_button.title = ally.title
		ally_button.rank = ally.get_rank()


func _on_visibility_changed() -> void:
	if visible:
		populate_squad()
