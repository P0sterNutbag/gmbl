extends CanvasLayer

var crosshair_target_pos: Vector2
@onready var middle_pos = DisplayServer.screen_get_size() / 4
@onready var crosshair = $Crosshair
@onready var player_hp_bar: ProgressBar = $ProgressBar


func _ready() -> void:
	Globals.ui = self


func _process(delta: float) -> void:
	crosshair.position = lerp(crosshair.position, crosshair_target_pos, 15 * delta)


func set_crosshair_position(pos: Vector2) -> void:
	crosshair_target_pos = pos


func reset_crosshair_position() -> void:
	crosshair_target_pos = middle_pos
