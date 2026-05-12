@tool
extends EditorScript

var directory_name := "res://Art/Themes/"
var new_color := Color(0.902, 0.855, 0.216, 1.0)
var icon_current_color := Color(1.0, 1.0, 1.0, 1.0)
var icons: Array = [
	"res://Art/Textures/UI/ammo icon.png",
	"res://Art/Textures/UI/armor icon.png",
	"res://Art/Textures/UI/arrow short left.png",
	"res://Art/Textures/UI/arrow_small.png",
	"res://Art/Textures/UI/arrow_small_left.png",
	"res://Art/Textures/UI/consumable icon.png",
	"res://Art/Textures/UI/cog icon.png",
	"res://Art/Textures/UI/crosshair007.png",
	"res://Art/Textures/UI/crosshair_point.png",
	"res://Art/Textures/UI/dice icon.png",
	"res://Art/Textures/UI/drunk icon.png",
	"res://Art/Textures/UI/faction icon.png",
	"res://Art/Textures/UI/gear icon.png",
	"res://Art/Textures/UI/gun icon.png",
	"res://Art/Textures/UI/hp icon.png",
	"res://Art/Textures/UI/hunger icon.png",
	"res://Art/Textures/UI/inventory icon.png",
	"res://Art/Textures/UI/journal icon.png",
	"res://Art/Textures/UI/mag icon.png",
	"res://Art/Textures/UI/pause icon.png",
	"res://Art/Textures/UI/population icon.png",
	"res://Art/Textures/UI/sleep icon.png",
	"res://Art/Textures/UI/target.png",
	"res://Art/Textures/UI/thirst icon.png",
	"res://Art/Textures/UI/trash icon.png",
	"res://Art/Textures/UI/mag icon sheet.png",
]


func _run() -> void:
	var dir = DirAccess.open(directory_name)
	var files = dir.get_files() 
	for file in files:
		var resource = load(directory_name + file)
		if resource is Theme:
			for type in resource.get_type_list():
				for color in resource.get_color_list(type):
					if color.contains("outline") or color.contains("shadow"):
						continue
					resource.set_color(color, type, new_color)
	var progress_box = load("res://Art/Themes/progress_bar_style_box.tres")
	progress_box.bg_color = new_color
	var style_box = load("res://Art/Themes/style_box.tres")
	style_box.border_color = new_color
	dir = DirAccess.open("res://Art/Textures/UI/")
	files = dir.get_files() 
	for icon_path in icons:
		var icon: Texture2D = load(icon_path)
		var img = icon.get_image().duplicate()
		img.decompress()
		for x in img.get_width():
			for y in img.get_height():
				var c: Color = img.get_pixel(x, y)
				if c == icon_current_color:
					img.set_pixel(x, y, new_color)
		img.save_png(icon_path)
