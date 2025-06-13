extends CanvasLayer

var crosshair_target_pos: Vector2
@onready var middle_pos = get_tree().root.get_viewport().size / 8
@onready var crosshair = $Crosshair
@onready var player_hp_bar: ProgressBar = %ProgressBar
@onready var hit_effect: Control = $HitEffect
@onready var scope: TextureRect = $Scope
@onready var center_dot: TextureRect = $TextureRect
@onready var mags_left: Label = %MagsLeft
@onready var medkits_left: Label = %MedkitsLeft
@onready var gun_name: Label = %GunName
@onready var exit_area: Label = $Label


func _ready() -> void:
	Globals.ui = self


#func _process(delta: float) -> void:
	#crosshair.position = lerp(crosshair.position, crosshair_target_pos, 15 * delta)
	#if Globals.player.state == Globals.player.states.dead:
		#hit_effect.show()
		#hit_effect.modulate.a = 1


func set_crosshair_position(pos: Vector2) -> void:
	crosshair_target_pos = pos


func reset_crosshair_position() -> void:
	crosshair_target_pos = middle_pos


func show_crosshairs():
	crosshair.show()
	center_dot.show()


func hide_crosshairs() -> void:
	crosshair.hide()
	center_dot.hide()


func show_scope(scope_texture: Texture2D = scope.texture) -> void:
	scope.texture = scope_texture
	scope.show()


func set_mag_count(amount: int) -> void:
	mags_left.text = str(amount)


func set_medit_count(amount: int) -> void:
	medkits_left.text = str(amount)


func set_gun_name(new_name: String) -> void:
	gun_name.text = new_name


func play_hit_effect() -> void:
	hit_effect.visible = true
	hit_effect.modulate.a = 1
	var tween = create_tween()
	tween.tween_property(hit_effect, "modulate:a", 0, 0.25)
	tween.tween_property(hit_effect, "visible", false, 0)
