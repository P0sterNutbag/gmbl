extends CanvasLayer

var show_crosshair: bool = true
@onready var middle_pos = get_tree().root.get_viewport().size / 8
@onready var crosshair = $Crosshair
@onready var player_hp_bar: ProgressBar = %ProgressBar
@onready var hit_effect: Control = $HitEffect
@onready var scope: TextureRect = $Scope
@onready var mags_left: Label = %MagsLeft
@onready var gun_name: Label = %GunName
@onready var exit_area: Label = $Label
@onready var mag_icon: Sprite2D = %MagIcon
@onready var death_ui: PanelContainer = $DeathUI
@onready var load_save: Button = $DeathUI/MarginContainer/VBoxContainer/VBoxContainer/LoadSave
@onready var bottom_right: Control = $BottomRight
@onready var tooltip: Label = $Tooltip
@onready var hit_indicator: TextureRect = %HitIndicator
@onready var dot_crosshair: ColorRect = $DotCrosshair
@onready var breath: ProgressBar = $Breath


func _ready() -> void:
	Globals.ui = self


func _process(delta: float) -> void:
	# tooltip
	if UiController.current_ui != null:
		tooltip.hide()
	else:
		tooltip.show()
	
	# magazine/medkits
	if Globals.player.gun and Globals.player.gun is Gun:
		bottom_right.visible = true
		set_mag_count(PlayerStats.inventory.get_item_amount(Globals.player.gun.ammo_item))
		#set_medit_count(PlayerStats.inventory.get_item_amount("medkit"))
		if Globals.player.gun.max_ammo > 0:
			var current_ammo = float(Globals.player.gun.ammo)
			var max_ammo = float(Globals.player.gun.max_ammo)
			var ammo_percentage = current_ammo / max_ammo
			var sprite_index = int(ammo_percentage * 20)
			if sprite_index == 0 and current_ammo > 0:
				sprite_index = 1
			mag_icon.region_rect = Rect2(sprite_index * 28, 0, 28, mag_icon.region_rect.size.y)
	else:
		bottom_right.visible = false
	
	# breath
	#if Globals.player.gun_state == Globals.player.gun_states.ads and Globals.player.current_breath < Globals.player.max_breath:
		#breath.visible = true
		#breath.value = Globals.player.current_breath / Globals.player.max_breath
	#else:
		#breath.visible = false

	
	# crosshair
	if (!show_crosshair or !Globals.player.gun or Globals.player.gun != Gun or
	Globals.player.gun_state == Globals.player.gun_states.ads or 
	Globals.player.gun_state == Globals.player.gun_states.no_gun or 
	tooltip.text != "" or Globals.crosshair_type == Globals.crosshairs.none or
	UiController.current_ui):
		crosshair.hide()
		return
	else:
		crosshair.show()
	if Globals.crosshair_type == Globals.crosshairs.dot:
		dot_crosshair.show()
		crosshair.hide()
		return
	var base_pos = clamp(Globals.player.gun.bullet_stats.h_angle_variance_hip * 20, 1, 100)
	for child in crosshair.get_children():
		var target_pos = child.position
		if child.position.x == 0:
			target_pos.y = sign(child.position.y) * (base_pos * clamp(Globals.player.velocity.length(), 1, 2) * Globals.player.gun.spread)
		elif child.position.y == 0:
			target_pos.x = sign(child.position.x) * (base_pos * clamp(Globals.player.velocity.length(), 1, 2) * Globals.player.gun.spread)
		child.position = lerp(child.position, target_pos, delta * 20)
	


func show_scope(scope_texture: Texture2D = scope.texture) -> void:
	scope.texture = scope_texture
	scope.show()


func set_mag_count(amount: int) -> void:
	mags_left.text = str(amount)


func set_gun_name(new_name: String) -> void:
	gun_name.text = new_name


func play_hit_effect(hit_direction: Vector3) -> void:
	# red flash
	hit_effect.show()
	hit_effect.modulate.a = 1
	var tween = create_tween()
	tween.tween_property(hit_effect, "modulate:a", 0, 0.25)
	tween.tween_property(hit_effect, "visible", false, 0)
	# hit indicator
	hit_indicator.show()
	hit_indicator.modulate.a = 1
	var b_basis = Basis.from_euler(hit_direction)
	var b_fwd = -b_basis.z
	b_fwd.y = 0.0
	b_fwd = b_fwd.normalized()
	var bullet_yaw = atan2(b_fwd.x, b_fwd.z)
	bullet_yaw = wrapf(bullet_yaw + PI, -PI, PI)
	var c_basis = Basis.from_euler(Globals.player.global_rotation)
	var c_fwd = -c_basis.z
	c_fwd.y = 0.0
	c_fwd = c_fwd.normalized()
	var cam_yaw = atan2(c_fwd.x, c_fwd.z)
	var delta_yaw = wrapf(bullet_yaw - cam_yaw, -PI, PI)
	hit_indicator.get_parent().rotation = -delta_yaw
	var tween2 = create_tween()
	tween2.tween_property(hit_indicator, "modulate:a", 0, 1)
	tween2.tween_property(hit_indicator, "visible", false, 0)


func _on_player_inventory_exit() -> void:
	PlayerStats.change_state(PlayerStats.states.walk)


func _on_transfer_inventory_exit() -> void:
	PlayerStats.change_state(PlayerStats.states.walk)


func open_death_ui() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	death_ui.show()
	#if Input.get_connected_joypads().size() > 0:
		#load_save.grab_focus()


func _on_load_save_pressed() -> void:
	#SceneManager.load_on_enter = true
	if Globals.overworld:
		Globals.overworld.queue_free()
	PlayerStats.reset_stats()
	SceneManager.start_scene_transition("res://Scenes/UI/Levels/character_creation.tscn")


func _on_quit_pressed() -> void:
	SceneManager.start_scene_transition("res://Scenes/UI/main_menu.tscn")


func _on_quit_2_pressed() -> void:
	get_tree().quit()
