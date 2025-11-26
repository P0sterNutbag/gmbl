extends Button
class_name MenuItem

var amount: int = 1:
	set(value):
		amount = value
		text = resource.title
		if amount <= 1: 
			return
		text += " (" + str(value) + ")"
#var equipped: bool:
	#set(value):
		#equipped = value
		##text = text.rstrip("*")
		#if equipped:
			#hide()
			##text += "*"
		#else:
			#show()
var price: int:
	set(value):
		price = value
		price_label.text = ""
		if value > 0:
			price_label.text += "$" + str(price)
var resource: Resource
var icon_texture: Texture2D
var can_press: bool
@onready var price_label: Label = %Price


func _ready() -> void:
	icon_texture = icon
	icon = null
	await get_tree().create_timer(0.1).timeout
	can_press = true


func _process(_delta: float) -> void:
	# select
	if Input.is_action_just_pressed("interact") and has_focus() and can_press:
		pressed.emit()


func _on_focus_entered() -> void:
	if !disabled:
		icon = icon_texture


func _on_focus_exited() -> void:
	if !disabled:
		icon = null


func _on_mouse_entered() -> void:
	grab_focus()


func _on_mouse_exited() -> void:
	release_focus()
