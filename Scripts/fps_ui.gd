extends CanvasLayer

var starting_fog: float
@onready var middle_pos = get_tree().root.get_viewport().size / 8
@onready var crosshair = $Crosshair
@onready var player_hp_bar: ProgressBar = %ProgressBar
@onready var hit_effect: Control = $HitEffect
@onready var scope: TextureRect = $Scope
@onready var mags_left: Label = %MagsLeft
@onready var exit_area: Label = $Label
@onready var mag_icon: Sprite2D = %MagIcon
@onready var death_ui: PanelContainer = $DeathUI
@onready var load_save: Button = $DeathUI/MarginContainer/VBoxContainer/VBoxContainer/LoadSave
@onready var ammo_count: Control = $AmmoCount
@onready var tooltip: HBoxContainer = $Tooltip
@onready var tooltip_holder: VBoxContainer = $Tooltip/VBoxContainer
@onready var hit_indicator: TextureRect = %HitIndicator
@onready var dot_crosshair: ColorRect = $DotCrosshair
@onready var breath: ProgressBar = $Breath
@onready var binocular_overlay: Control = $BinocularOverlay
@onready var commands: VBoxContainer = $Commands
@onready var commands_label: Label = $Commands/Label2
@onready var ally_count: Label = $Commands/HBoxContainer/Label


func _ready() -> void:
	Globals.ui = self
	var shader = get_tree().root.get_node("Encounter/Shader").mesh.material
	starting_fog = shader.get_shader_parameter("fog_end")


func _process(delta: float) -> void:
	# tooltip
	if UiController.current_ui != null:
		tooltip.hide()
	
	# ally commands
	if Input.is_action_pressed("command_allies"):
		commands.show()
		ally_count.text = str(PlayerStats.allies.size())
	else:
		commands.hide()
	
	if Input.is_action_pressed("light") and Input.is_action_just_pressed("aim"):
		if visible:
			hide()
		else:
			show()
	#if commands.visible:
		#var text = "1: "
		#if PlayerStats.allies_follow: text += "Stop"
		#else: text += "Follow"
		#text += "\n2: "
		#if PlayerStats.allies_shoot: text += "Hold Fire"
		#else: text += "Open Fire"
		#commands_label.text = text
	
	# magazine visual and count
	if Globals.player.gun:
		if Globals.player.gun is Gun:
			ammo_count.visible = true
			mag_icon.visible = true
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
		elif PlayerStats.gun and PlayerStats.gun.stackable:
			ammo_count.visible = true
			mag_icon.visible = false
			var weapon_count = PlayerStats.inventory.get_item_amount(PlayerStats.gun)
			set_mag_count(weapon_count)
	else:
		ammo_count.visible = false
	
	# breath
	if Globals.player.gun_state == Globals.player.gun_states.ads and Globals.player.current_breath < Globals.player.max_breath:
		breath.visible = true
		breath.value = Globals.player.current_breath / Globals.player.max_breath
	else:
		breath.visible = false
	
	# crosshair
	match Globals.crosshair_type:
		Globals.crosshairs.standard:
			crosshair.show()
			dot_crosshair.hide()
			if (!Globals.player.gun or Globals.player.gun is not Gun or
			Globals.player.gun_state == Globals.player.gun_states.no_gun):
				crosshair.hide()
				dot_crosshair.show()
			if (tooltip.visible or Globals.crosshair_type == Globals.crosshairs.none or UiController.current_ui
			or Globals.player.gun_state == Globals.player.gun_states.ads):
				crosshair.hide()
				dot_crosshair.hide()
			if crosshair.visible:
				var base_pos = clamp(Globals.player.gun.modified_spread * 20, 1, 100)
				for child in crosshair.get_children():
					var target_pos = child.position
					if child.position.x == 0:
						target_pos.y = base_pos * sign(child.position.y)
					elif child.position.y == 0:
						target_pos.x = base_pos * sign(child.position.x)
					child.position = lerp(child.position, target_pos, delta * 20)
		Globals.crosshairs.dot:
			dot_crosshair.show()
			crosshair.hide()
			if UiController.current_ui and tooltip.visible:
				dot_crosshair.hide()
		Globals.crosshairs.none:
			crosshair.hide()
			dot_crosshair.hide()


func show_scope(scope_texture: Texture2D = scope.texture) -> void:
	scope.texture = scope_texture
	UiController.open_interface(scope, false, false)#scope.show()
	var shader = get_tree().current_scene.get_node("Shader").mesh.material
	shader.set_shader_parameter("fog_end", starting_fog * 1.75)


func hide_scope() -> void: 
	UiController.close_interface(scope, false)#scope.hide()
	var shader = get_tree().current_scene.get_node("Shader").mesh.material
	shader.set_shader_parameter("fog_end", starting_fog)


func set_mag_count(amount: int) -> void:
	mags_left.text = str(amount)


func set_tooltip(collider: InteractableObject):
	if "health_component" in collider and !collider.health_component.is_dead:
		return
	tooltip.show()
	for child in tooltip_holder.get_children():
		child.text = ""
	for i in collider.actions.size():
		var label : Label = tooltip_holder.get_child(i)
		label.text = collider.actions[i]
		if i != collider.index:
			label.add_theme_color_override("font_color", Color(0.446, 0.446, 0.0, 1.0))
		else:
			label.remove_theme_color_override("font_color")


func set_tooltip_custom(text: String):
	tooltip.show()
	for i in tooltip_holder.get_child_count():
		var label : Label = tooltip_holder.get_child(i)
		label.remove_theme_color_override("font_color")
		if i == 0:
			label.text = text
		else:
			label.text = ""


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
	var c_basis = Basis.from_euler(Globals.player.camera.global_rotation)
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
	SceneManager.start_scene_transition("res://Scenes/UI/Levels/character_creation.tscn")


func _on_quit_pressed() -> void:
	SceneManager.start_scene_transition("res://Scenes/UI/Levels/main_menu.tscn")


func _on_quit_2_pressed() -> void:
	get_tree().quit()


func _on_binocular_overlay_visibility_changed() -> void:
	var shader = get_tree().current_scene.get_node("Shader").mesh.material
	if binocular_overlay.visible:
		shader.set_shader_parameter("fog_end", starting_fog * 1.75)
	else:
		shader.set_shader_parameter("fog_end", starting_fog)
