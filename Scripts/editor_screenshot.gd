@tool
extends EditorScript


func _run() -> void:
	var viewport = EditorInterface.get_editor_viewport_3d(0)
	var img = viewport.get_texture().get_image()
	
	var file_name = "preview.png"
	var counter = 1
	
	while FileAccess.file_exists("res://" + file_name):
		file_name = "preview_%03d.png" % counter
		counter += 1
	
	img.save_png("res://" + file_name)
	print("Screenshot saved as: " + file_name)
