extends Placeable

var max_oil: float = 100
var current_oil: float = 0
var speed: float = 1
var progress_bar: GradientTexture1D
@onready var sprite_3d: Sprite3D = $MeshInstance3D/Sprite3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	progress_bar = sprite_3d.texture


func _process(delta: float) -> void:
	super._process(delta)
	sprite_3d.modulate.a = 255 - (mesh_instance_3d.transparency * 255)
	if !placed:
		return
	if current_oil <= max_oil:
		current_oil += delta * speed
		progress_bar.gradient.offsets[1] = 1 - (current_oil / max_oil)
