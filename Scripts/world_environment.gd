extends WorldEnvironment

@export var sky_gradient: GradientTexture1D
@export var horizon_gradient: GradientTexture1D
@export var time_curve: Curve
var sky_energy: float = 1.0
var max_sky_energy: float = 1.0
var min_sky_energy: float = 0.05
var sky_color: Color
var horizon_color: Color
var shader: Node3D
@onready var sun: DirectionalLight3D = $DirectionalLight3D


func _ready() -> void:
	shader = get_tree().current_scene.get_node_or_null("Shader")


func _process(_delta: float) -> void:
	sky_color = sky_gradient.get_gradient().sample(DayNightCycle.sky_progress)
	horizon_color = horizon_gradient.get_gradient().sample(DayNightCycle.sky_progress)
	#environment.sky.sky_material.energy_multiplier = sky_energy
	environment.ambient_light_energy = clamp(DayNightCycle.time_curve.sample(DayNightCycle.time), min_sky_energy, max_sky_energy)
	environment.sky.sky_material.sky_top_color = sky_color
	environment.sky.sky_material.sky_horizon_color = horizon_color
	environment.sky.sky_material.ground_bottom_color = horizon_color
	environment.sky.sky_material.ground_horizon_color = horizon_color
	shader.mesh.material.set_shader_parameter("fog_color", horizon_color)
	sun.rotation.x = lerp(deg_to_rad(90), deg_to_rad(-90), DayNightCycle.sky_progress)
	sun.light_energy = time_curve.sample(DayNightCycle.time)
