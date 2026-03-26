extends MenuList

@onready var vbox_container: MenuController = $MarginContainer/VBoxContainer


func _ready() -> void:
	item_container = vbox_container


func _on_visibility_changed() -> void:
	if visible:
		open(PlayerStats.allies)
