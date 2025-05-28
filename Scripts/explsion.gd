extends Area3D

var dmg = 3
var timer: float

func _process(delta: float) -> void:
	timer += delta
	if timer > 0.05:
		queue_free()

func _on_area_entered(area: Area3D) -> void:
	area.damage(dmg)
	queue_free()
