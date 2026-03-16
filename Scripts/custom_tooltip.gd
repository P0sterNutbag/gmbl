extends Control

var tooltip_theme = preload("res://Art/Themes/text_small_outline.tres")


func _make_custom_tooltip(for_text):
	var label = Label.new()
	label.text = for_text
	label.theme = tooltip_theme
	return label
