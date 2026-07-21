extends Area3D

@export var filter_color : Color = Color("ff6b00")
var original_color
var overlay


func _enter_tree() -> void:
	monitoring = true


func _ready() -> void:
	overlay = get_tree().root.get_node("Overlay")
	original_color = overlay.get_tint_color()
	SceneManager.transition_started.connect(_on_transition_started)


func _on_body_entered(_body: Node3D) -> void:
	overlay.set_tint_color(filter_color)


func _on_body_exited(_body: Node3D) -> void:
	if !monitoring:
		return
	overlay.set_tint_color(original_color)


func _on_transition_started(_scene) -> void:
	monitoring = false
