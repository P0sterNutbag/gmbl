extends Resource
class_name ProgressData

@export var xp := 0
@export var level := 1


func add_xp(xp_to_add: int) -> void: 
	xp += xp_to_add
	while xp >= 100:
		level += 1
		xp -= 100
