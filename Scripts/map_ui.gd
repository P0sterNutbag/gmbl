extends PanelContainer

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var texture_rect: TextureRect = $ScrollContainer/TextureRect


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass


func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("shoot"):
		scroll_container.scroll_horizontal -= event.relative.x
		scroll_container.scroll_vertical -= event.relative.y
	if event is InputEventMouseButton:
		if Input.is_action_pressed("next_gun"):
			texture_rect.custom_minimum_size *= 1.1
		if Input.is_action_pressed("last_gun"):
			texture_rect.custom_minimum_size *= 0.9
