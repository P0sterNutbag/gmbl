extends Location

var stash_path = "user://stash.res"


func save() -> Dictionary:
	var stash = town.shops[0].inventory
	ResourceSaver.save(stash, stash_path)
	return super.save()


func _on_load() -> void:
	if ResourceLoader.exists(stash_path):
		var stash = ResourceLoader.load(stash_path)
		town.shops[0].inventory = stash
	super._on_load()
