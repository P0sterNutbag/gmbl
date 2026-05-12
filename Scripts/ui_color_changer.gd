@tool
extends EditorScript

var directory_name := "res://Art/Themes/"
static var new_color := Color(0.902, 0.0, 0.224, 1.0)
static var text_color := Color(1.0, 0.12, 0.281, 1.0)
var icons: Array = [
	"res://Art/Textures/UI/ammo icon.png",
	"res://Art/Textures/UI/armor icon.png",
	"res://Art/Textures/UI/arrow short left.png",
	"res://Art/Textures/UI/arrow short.png",
	"res://Art/Textures/UI/arrow.png",
	"res://Art/Textures/UI/arrow_small.png",
	"res://Art/Textures/UI/arrow_small_left.png",
	"res://Art/Textures/UI/consumable icon.png",
	"res://Art/Textures/UI/cursor.png",
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
	"res://Art/Textures/UI/slider_grabber.png",
	"res://Art/Textures/UI/target.png",
	"res://Art/Textures/UI/thirst icon.png",
	"res://Art/Textures/UI/trash icon.png",
	"res://Art/Textures/UI/mag icon sheet.png",]
var cool_boy_yellow = Color(0.902, 0.855, 0.216, 1.0)
var slightly_darker_yellow = Color(0.78, 0.74, 0.187, 1.0) 
var light_yellow := Color(1.0, 0.956, 0.34, 1.0)


func _run() -> void:
	var dir = DirAccess.open(directory_name)
	var files = dir.get_files() 
	for file in files:
		var resource := ResourceLoader.load(directory_name + file, "", ResourceLoader.CACHE_MODE_IGNORE)
		if resource is Theme:
			for type in resource.get_type_list():
				for color in resource.get_color_list(type):
					if color.contains("outline") or color.contains("shadow"):
						continue
					resource.set_color(color, type, text_color)
		if resource is StyleBox:
			if resource.bg_color.a == 1 and resource.draw_center:
				resource.bg_color = new_color
			else:
				resource.border_color = new_color
		ResourceSaver.save(resource, directory_name + file)
		ResourceLoader.load(directory_name + file, "", ResourceLoader.CACHE_MODE_REPLACE)
	
	dir = DirAccess.open("res://Art/Textures/UI/")
	files = dir.get_files() 
	var current_color = load("res://Art/Textures/UI/thirst icon.png").get_image().get_pixel(0,0)
	for icon_path in icons:
		var icon: Texture2D = load(icon_path)
		var img = icon.get_image().duplicate()
		img.decompress()
		for x in img.get_width():
			for y in img.get_height():
				var c: Color = img.get_pixel(x, y)
				if (abs(c.r - current_color.r) < 0.1 and 
				abs(c.g - current_color.g) < 0.1 and 
				abs(c.b - current_color.b) < 0.1):
					new_color.a = c.a
					new_color.v = c.v
					img.set_pixel(x, y, new_color)
		img.save_png(icon_path)
		ResourceLoader.load(icon_path, "", ResourceLoader.CACHE_MODE_REPLACE)
