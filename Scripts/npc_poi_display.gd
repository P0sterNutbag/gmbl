extends HoverDisplay

var parent: Node3D
@onready var population: Label = %Population


func _ready() -> void:
	super._ready()
	parent = get_parent()


func _process(delta: float) -> void:
	super._process(delta)
	population.text = str(parent.location.location_data.population)
