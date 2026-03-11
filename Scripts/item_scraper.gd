@tool
extends EditorScript

var item_prices = preload("uid://bhgje5ioc8fmf")


func _run() -> void:
	item_prices.prices.clear()
	var dir = DirAccess.open("res://Resources/Items/")
	var dirs = dir.get_directories()
	for _dir in dirs:
		var dir_name = "res://Resources/Items/" + _dir + "/"
		dir = DirAccess.open(dir_name)
		item_prices.prices[_dir.to_upper()] = 0
		var files = dir.get_files() 
		for file in files:
			if file.contains(".tmp") or file.contains(".depren"):
				continue
			var resource = load(dir_name + file)
			item_prices.prices[file] = resource.price
	print("items scraped")
	notify_property_list_changed()
	pass
