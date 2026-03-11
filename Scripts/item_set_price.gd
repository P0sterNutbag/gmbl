@tool
extends EditorScript

var item_prices = preload("uid://bhgje5ioc8fmf")


func _run() -> void:
	var dir = DirAccess.open("res://Resources/Items/")
	var dirs = dir.get_directories()
	for _dir in dirs:
		var dir_name = "res://Resources/Items/" + _dir + "/"
		dir = DirAccess.open(dir_name)
		var files = dir.get_files() 
		for file in files:
			if file.contains(".tmp") or file.contains(".depren"):
				continue
			var resource = load(dir_name + file)
			if item_prices.prices.has(file):
				resource.price = item_prices.prices[file]
	print("items price set")
	notify_property_list_changed()
	pass
