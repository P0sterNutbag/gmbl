extends WorldEnvironment

@export var sky_gradient: GradientTexture1D
@export var horizon_gradient: GradientTexture1D
@export var sun_energy_curve: Curve
@export var sky_energy_curve: Curve
var sky_energy: float = 1.0
var sky_color: Color
var horizon_color: Color
var shader: Node3D
@onready var sun: DirectionalLight3D = $DirectionalLight3D


func _ready() -> void:
	sun.rotation.y = deg_to_rad(-90)
	await get_tree().process_frame
	shader = get_tree().current_scene.get_node_or_null("Shader")


func _process(_delta: float) -> void:
	sky_color = sky_gradient.get_gradient().sample(DayNightCycle.sky_progress)
	horizon_color = horizon_gradient.get_gradient().sample(DayNightCycle.sky_progress)
	environment.sky.sky_material.sky_top_color = sky_color
	environment.sky.sky_material.sky_horizon_color = horizon_color
	environment.sky.sky_material.ground_bottom_color = horizon_color
	environment.sky.sky_material.ground_horizon_color = horizon_color
	if DayNightCycle.normalized_time > 0:
		sun.rotation.x = lerp(deg_to_rad(10), deg_to_rad(-190), DayNightCycle.sun_time)
	sun.light_energy = sun_energy_curve.sample(DayNightCycle.normalized_time)
	environment.ambient_light_energy = sky_energy_curve.sample(DayNightCycle.normalized_time)
	environment.sky.sky_material.energy_multiplier = sky_energy_curve.sample(DayNightCycle.normalized_time)
	if shader:
		shader.mesh.material.set_shader_parameter("fog_color", horizon_color)
