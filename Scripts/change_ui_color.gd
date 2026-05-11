@tool
extends EditorScript

var directory_name := "res://Art/Themes/"
var new_color := Color(0.902, 0.855, 0.216, 1.0)
var icons: Array = [
	"res://Art/Textures/UI/ammo icon.png",
	"res://Art/Textures/UI/armor icon.png",
	"res://Art/Textures/UI/arrow short left.png",
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
		elif resource is StyleBox:
			resource.border_color = new_color
	dir = DirAccess.open("res://Art/Textures/UI/")
	files = dir.get_files() 
	for icon_path in icons:
		var icon: Texture2D = load(icon_path)
		var img = icon.get_image().duplicate()
		img.decompress()
		for x in img.get_width():
			for y in img.get_height():
				var c: Color = img.get_pixel(x, y)
				if c == Color(1.0, 1.0, 1.0, 1.0):
					img.set_pixel(x, y, new_color)
		img.save_png(icon_path)
	notify_property_list_changed()
