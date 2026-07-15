extends HoverDisplay

@onready var population_label: Label = %Population


func _process(delta: float) -> void:
	super._process(delta)
	var population = PlayerStats.allies.size() + 1
	if population > 1:
		show()
		population_label.text = str(population)
	else: 
		hide()
