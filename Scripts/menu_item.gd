extends Button


var amount: int = 1:
	set(value):
		amount = value
		if amount <= 1: 
			text = text.rstrip("(1234567890)")
			return
		text += "(" + str(value) + ")"
var equipped: bool:
	set(value):
		equipped = value
		text = text.rstrip("*")
		if equipped:
			text += "*"
var price: int:
	set(value):
		price = value
		price_label.text = ""
		if value > 0:
			price_label.text += "$" + str(price)
var item: Item
var icon_texture: Texture2D
var can_press: bool
@onready var price_label: Label = %Price


func _ready() -> void:
	icon_texture = icon
	icon = null
	await get_tree().process_frame
	can_press = true


func _process(delta: float) -> void:
	# select
	if Input.is_action_just_pressed("interact") and has_focus() and can_press:
		pressed.emit()
	# show equipped
	if item and item is Equipment:
		equipped = item.equipped


func _on_focus_entered() -> void:
	icon = icon_texture


func _on_focus_exited() -> void:
	icon = null
