extends Menu

var overlay: CanvasLayer
@onready var resolution: Button = %Resolution
@onready var fullscreen: Button = %Fullscreen
@onready var volume: SliderButton = %Volume
@onready var music_volume: SliderButton = %MusicVolume
@onready var sfx_volume: SliderButton = %SfxVolume
@onready var aim_sensitivity: SliderButton = %AimSensitivity
@onready var crt: Button = %CRT
@onready var warp: Button = %Warp
@onready var crosshair: Button = %Crosshair
@onready var aspect_ratio: Button = %AspectRatio
@onready var show_ammo: Button = %ShowAmmo


func _ready() -> void:
	overlay = get_tree().root.get_node("Overlay")
	fullscreen.toggled.emit(SettingsController.fullscreen)
	resolution.set_index_by_value(SettingsController.resolution)
	volume.h_slider.value = SettingsController.master_volume
	music_volume.h_slider.value = SettingsController.music_volume
	sfx_volume.h_slider.value = SettingsController.sfx_volume
	aim_sensitivity.h_slider.value = SettingsController.mouse_sentitivity
	crt.toggled.emit(SettingsController.crt)
	crosshair.set_index_by_value(SettingsController.crosshair)
	show_ammo.toggled.emit(SettingsController.show_ammo)


func _on_master_h_slider_value_changed(value: float) -> void:
	SettingsController.set_master_volume(value)


func _on_music_h_slider_value_changed(value: float) -> void:
	SettingsController.set_music_volume(value)


func _on_sfx_h_slider_value_changed(value: float) -> void:
	SettingsController.set_sfx_volume(value)


func _on_back_pressed() -> void:
	hide()


func _on_warp_toggled(toggled_on: bool) -> void:
	SettingsController.set_warp(toggled_on)


func _on_crt_toggled(toggled_on: bool) -> void:
	SettingsController.set_crt(toggled_on)


func _on_crosshair_option_changed(value: Variant) -> void:
	SettingsController.set_crosshair(value)


func _on_aim_sensitivity_h_slider_value_changed(value: float) -> void:
	SettingsController.set_aim_sensitivity(value)


func _on_resolution_option_changed(value: Variant) -> void:
	if resolution.visible:
		SettingsController.set_resolution(value)


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	SettingsController.set_fullscreen(toggled_on)
	resolution.visible = !toggled_on


func _on_aspect_ratio_option_changed(value: Variant) -> void:
	SettingsController.set_aspect_ratio(value)


func _on_hide_hud_toggled(toggled_on: bool) -> void:
	SettingsController.set_hud(toggled_on)
