extends Location

@onready var item_search: Control = $ItemSearch


func _on_area_3d_body_entered(body: Node3D) -> void:
	item_search.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	item_search.hide()
