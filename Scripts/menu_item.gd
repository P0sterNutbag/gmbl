extends UiButton
class_name MenuItem

var amount: int = 1:
	set(value):
		amount = value
		text = resource.title
		if amount <= 1: 
			return
		text += " (" + str(value) + ")"
var price: int:
	set(value):
		price = value
		price_label.text = ""
		if value > 0:
			price_label.text += "$" + str(price)
var resource: Resource
@onready var price_label: Label = %Price
