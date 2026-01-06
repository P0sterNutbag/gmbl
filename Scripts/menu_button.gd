extends Button
class_name UiButton

var icon_texture: Texture2D
var can_press: bool
@export var show_icon_on_focus: bool = true


func _ready() -> void:
	if show_icon_on_focus:
		icon_texture = icon
		icon = null
	if !mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if !mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)
	if !focus_entered.is_connected(_on_focus_entered):
		focus_entered.connect(_on_focus_entered)
	if !focus_exited.is_connected(_on_focus_exited):
		focus_exited.connect(_on_focus_exited)
	await get_tree().create_timer(0.1).timeout
	can_press = true


func _process(_delta: float) -> void:
	# select
	if Input.is_action_just_pressed("select") and has_focus() and can_press:
		pressed.emit()


func _on_focus_entered() -> void:
	if !disabled and show_icon_on_focus:
		icon = icon_texture


func _on_focus_exited() -> void:
	if !disabled and show_icon_on_focus:
		icon = null


func _on_mouse_entered() -> void:
	grab_focus()


func _on_mouse_exited() -> void:
	release_focus()
