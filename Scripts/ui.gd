extends CanvasLayer

var crosshair_target_pos: Vector2
var middle_pos = Vector2(320, 240)
@onready var crosshair = $Crosshair

func _ready() -> void:
	Globals.ui = self


func _process(delta: float) -> void:
	crosshair.position = lerp(crosshair.position, crosshair_target_pos, 15 * delta)


func set_crosshair_position(pos: Vector2) -> void:
	crosshair_target_pos = pos


func reset_crosshair_position() -> void:
	crosshair_target_pos = middle_pos
