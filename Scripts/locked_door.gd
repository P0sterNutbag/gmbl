extends InteractableObject


func _ready() -> void:
	actions = ["Unlock"]


func interact() -> void:
	super.interact()
	if index == 0:
		var key = PlayerStats.inventory.find_item("gate key")
		if key:
			var tween = create_tween()
			tween.tween_property(owner, "rotation:y", deg_to_rad(-90), 1)
			PlayerStats.inventory.remove_item(key, 1, true)
			actions = []
		else:
			Globals.survival_ui.create_notification("Missing gate key")
