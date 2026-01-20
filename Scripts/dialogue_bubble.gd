extends PanelContainer

@onready var label: Label = $MarginContainer/Label
@onready var line: Line2D = $Control/Line2D
var can_proceed: bool = false
var text: String: 
	set(value):
		text = value
		start_typewriter(value)


func _process(_delta: float) -> void:
	var length = -size.x + 2
	line.set_point_position(3, Vector2(length, 0))
	if Input.is_action_just_pressed("select") or Input.is_action_just_pressed("shoot"):
		if !can_proceed:
			can_proceed = true
			label.text = text


func start_typewriter(new_text: String) -> void:
	label.text = ""
	for i in new_text:
		if can_proceed:
			return
		label.text += i
		await get_tree().create_timer(0.05).timeout
	can_proceed = true
