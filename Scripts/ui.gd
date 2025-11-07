extends CanvasLayer

var show_crosshair: bool = true
@onready var middle_pos = get_tree().root.get_viewport().size / 8
@onready var crosshair = $Crosshair
@onready var player_hp_bar: ProgressBar = %ProgressBar
@onready var player_hp_bar2: ProgressBar = %ProgressBar2
@onready var hit_effect: Control = $HitEffect
@onready var scope: TextureRect = $Scope
@onready var mags_left: Label = %MagsLeft
@onready var medkits_left: Label = %MedkitsLeft
@onready var gun_name: Label = %GunName
@onready var exit_area: Label = $Label
@onready var inventory_container: HBoxContainer = $PlayerInventory
@onready var inventory_container2: HBoxContainer = $TransferInventory
@onready var inventory: PanelContainer = %Inventory
@onready var inventory2: PanelContainer = %Inventory2
@onready var mag_icon: Sprite2D = $BottomRight/Sprite
@onready var death_ui: PanelContainer = $DeathUI
@onready var load_save: Button = $DeathUI/MarginContainer/VBoxContainer/VBoxContainer/LoadSave
@onready var bottom_right: Control = $BottomRight

#@onready var compass: ColorRect = $TopCenter/Compass/ColorRect


func _ready() -> void:
	Globals.ui = self


func _process(delta: float) -> void:
	# magazine/medkits
	if Globals.player.gun:
		bottom_right.visible = true
		set_mag_count(PlayerStats.get_item_amount(Globals.player.gun.ammo_type))
		set_medit_count(PlayerStats.get_item_amount("medkit"))
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
	
	# inventory
	if Input.is_action_just_pressed("inventory"):
		inventory_container.visible = !inventory_container.visible
		if inventory_container.visible:
			PlayerStats.change_state(PlayerStats.states.pause)
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			PlayerStats.change_state(PlayerStats.states.walk)
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# crosshair
	if get_tree().current_scene == Globals.overworld:
		return
	if !show_crosshair or !Globals.player.gun or Globals.player.gun_state == Globals.player.gun_states.ads or Globals.player.gun_state == Globals.player.gun_states.no_gun:
		crosshair.hide()
		return
	else:
		crosshair.show()
	var base_pos = clamp(Globals.player.gun.bullet_stats.h_angle_variance_hip * 20, 1, 100)
	for child in crosshair.get_children():
		var target_pos = child.position
		if child.position.x == 0:
			target_pos.y = sign(child.position.y) * (base_pos * clamp(Globals.player.velocity.length(), 1, 2) * Globals.player.shoot_component.spread)
		elif child.position.y == 0:
			target_pos.x = sign(child.position.x) * (base_pos * clamp(Globals.player.velocity.length(), 1, 2) * Globals.player.shoot_component.spread)
		child.position = lerp(child.position, target_pos, delta * 20)
	


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


func loot(target) -> void:
	PlayerStats.change_state(PlayerStats.states.pause)
	inventory.mode = inventory.modes.loot
	inventory2.mode = inventory2.modes.loot
	inventory.target2 = target
	inventory2.target = target
	inventory2.target2 = PlayerStats
	inventory2.grab_focus()
	inventory_container2.show()


func reset_inventoryies() -> void:
	inventory.set_items()
	inventory2.set_items()


func _on_player_inventory_exit() -> void:
	PlayerStats.change_state(PlayerStats.states.walk)


func _on_transfer_inventory_exit() -> void:
	PlayerStats.change_state(PlayerStats.states.walk)


func open_death_ui() -> void:
	death_ui.show()
	load_save.grab_focus()


func _on_load_save_pressed() -> void:
	#SceneManager.load_on_enter = true
	if Globals.overworld:
		Globals.overworld.queue_free()
	PlayerStats.reset_stats()
	SceneManager.start_scene_transition("res://Scenes/Overworld/overworld.tscn")


func _on_quit_pressed() -> void:
	SceneManager.start_scene_transition("res://Scenes/UI/main_menu.tscn")


func _on_quit_2_pressed() -> void:
	get_tree().quit()
