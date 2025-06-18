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
@onready var inventory_container: HBoxContainer = $PlayerInventory
@onready var inventory_container2: HBoxContainer = $TransferInventory
@onready var inventory: PanelContainer = %Inventory
@onready var inventory2: PanelContainer = %Inventory2


func _ready() -> void:
	Globals.ui = self


func _process(delta: float) -> void:
	set_mag_count(PlayerStats.get_item_amount(Globals.player.gun.ammo_type))
	set_medit_count(PlayerStats.get_item_amount("medkit"))
	if Input.is_action_just_pressed("inventory"):
		inventory_container.visible = !inventory_container.visible
		PlayerStats.change_state(PlayerStats.states.pause)


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
