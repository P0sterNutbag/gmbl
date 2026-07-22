extends Control

@onready var value_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Label2
@onready var condition_label: Label = $MarginContainer/VBoxContainer/HBoxContainer2/Label2
@onready var seller_label: Label = $MarginContainer/VBoxContainer/HBoxContainer3/Label2
@onready var final_value_label: Label = $MarginContainer/VBoxContainer/HBoxContainer4/Label2
@onready var condition_container: HBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer2


func set_item(item: Item, shop: Shop, menu_item: MenuItem) -> void:
	show()
	value_label.text = "$" + str(item.price)
	var seller_mod = 1 - shop.price_modifiers[owner.categories[item.category]]
	seller_label.text = "-%" + str(int(seller_mod * 100))
	if item is EquipmentGun:
		var difference = item.price - item.get_modified_price()
		if difference == 0:
			condition_container.hide()
		else:
			condition_container.show()
		condition_label.text = "-$" + str(difference)
	else:
		condition_container.hide()
	final_value_label.text = "$" + str(menu_item.price)
