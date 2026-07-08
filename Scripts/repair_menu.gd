extends MenuList

@export var uses_money: bool = true
@export var one_use: bool
var repair_amount := 100.0
@onready var money: Label = %Money
const REPAIR_BUTTON = preload("uid://bt5vwn1pyvjhq")


func _on_visibility_changed() -> void:
	if !visible:
		return
	money.text = "$" + str(PlayerStats.inventory.money)
	var guns = PlayerStats.inventory.items.filter(func(i): return i is EquipmentGun)
	open(guns, REPAIR_BUTTON)
	await get_tree().process_frame
	for i in item_container.get_child_count():
		var button = item_container.get_child(i)
		var resource = guns[i]
		button.progress_bar.front_bar.value = resource.condition
		button.progress_bar.back_bar.value = 0
		if resource.condition == 100:
			button.disabled = true
		elif uses_money:
			button.price = clamp(((100.0 - resource.condition) / 100.0) * (resource.price * 0.75), 10000, 10)
			button.money_label.text = button.price 
			button.money_label.show()


func on_button_pressed(button: Control, resource: Resource) -> void:
	super.on_button_pressed(button, resource)
	if !uses_money or PlayerStats.inventory.money >= button.price: 
		PlayerStats.inventory.money -= button.price
		money.text = "$" + str(PlayerStats.inventory.money)
		resource.gun_stats.condition = clamp(resource.gun_stats.condition + repair_amount, 0, 100)
		button.text = resource.title + " " + str(resource.condition) + " %"
		button.disabled = true
		button.icon = null
		button.price = 0
		if one_use:
			PlayerStats.inventory.remove_item_by_name("gun repair kit")
			UiController.close_subinterface()


func on_button_focus_entered(button: Control, resource: Resource) -> void:
	super.on_button_focus_entered(button, resource)
	button.progress_bar.back_bar.value = button.progress_bar.front_bar.value + repair_amount


func on_button_focus_exited(button: Control) -> void:
	super.on_button_focus_exited(button)
	button.progress_bar.back_bar.value = 0
