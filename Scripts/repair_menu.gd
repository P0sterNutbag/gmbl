extends MenuList

@onready var money: Label = $MarginContainer/VBoxContainer/Money


func _on_visibility_changed() -> void:
	if !visible:
		return
	money.text = "$" + str(PlayerStats.inventory.money)
	var guns = PlayerStats.inventory.items.filter(func(i): return i is EquipmentGun)
	open(guns)
	await get_tree().process_frame
	for i in item_container.get_child_count():
		var menu_item = item_container.get_child(i)
		var resource = guns[i]
		menu_item.text += " " + str(resource.condition) + " %"
		if resource.condition == 100:
			menu_item.disabled = true
		else:
			menu_item.price = clamp(((100.0 - resource.condition) / 100.0) * (resource.price * 0.75), 10000, 10)


func on_button_pressed(button: Control, resource: Resource) -> void:
	super.on_button_pressed(button, resource)
	if resource.condition < 100 and PlayerStats.inventory.money >= button.price: 
		PlayerStats.inventory.money -= button.price
		money.text = "$" + str(PlayerStats.inventory.money)
		resource.gun_stats.condition = 100
		button.text = resource.title + " " + str(resource.condition) + " %"
		button.disabled = true
		button.icon = null
		button.price = 0
