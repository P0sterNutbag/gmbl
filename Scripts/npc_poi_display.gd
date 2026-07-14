extends PoiDisplay

var parent: Node3D
@onready var title: Label = %Title
@onready var population: Label = %Population


func _ready() -> void:
	super._ready()
	parent = get_parent()


func _process(delta: float) -> void:
	super._process(delta)
	title.text = parent.location.title
	population.text = str(parent.location.location_data.population)
