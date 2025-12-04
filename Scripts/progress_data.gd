extends Resource
class_name ProgressData

@export var xp := 0
@export var level := 1


func add_xp(xp_to_add: int) -> void: 
	xp += xp_to_add
	if xp >= 100:
		xp -= 100
		level += 1
