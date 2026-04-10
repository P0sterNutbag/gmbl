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
const SKY_NIGHTTIME = preload("uid://dqycx3ovg1v54")
const SKY_DAYTIME = preload("uid://dqicgdsw2n7pd")


func _enter_tree() -> void:
	await get_tree().process_frame
	_on_scene_changed()

func _ready() -> void:
	sun.rotation.y = deg_to_rad(-90)
	SceneManager.scene_changed.connect(_on_scene_changed)


func _process(_delta: float) -> void:
	if DayNightCycle.is_night:
		if environment.sky.sky_material != SKY_NIGHTTIME:
			environment.sky.sky_material = SKY_NIGHTTIME
			var tween = create_tween()
			tween.tween_property(self, "horizon_color", Color(), 5)
	elif environment.sky.sky_material != SKY_DAYTIME:
		environment.sky.sky_material = SKY_DAYTIME
	if DayNightCycle.normalized_time > 0:
		sun.rotation.x = lerp(deg_to_rad(10), deg_to_rad(-190), DayNightCycle.sun_time)
	sun.light_energy = sun_energy_curve.sample(DayNightCycle.normalized_time)
	environment.ambient_light_energy = sky_energy_curve.sample(DayNightCycle.normalized_time)
	environment.sky.sky_material.energy_multiplier = sky_energy_curve.sample(DayNightCycle.normalized_time)
	if shader:
		shader.mesh.material.set_shader_parameter("fog_color", horizon_color)
	if environment.sky.sky_material is PanoramaSkyMaterial:
		return
	sky_color = sky_gradient.get_gradient().sample(DayNightCycle.sky_progress)
	horizon_color = horizon_gradient.get_gradient().sample(DayNightCycle.sky_progress)
	environment.sky.sky_material.sky_top_color = sky_color
	environment.sky.sky_material.sky_horizon_color = horizon_color
	environment.sky.sky_material.ground_bottom_color = horizon_color
	environment.sky.sky_material.ground_horizon_color = horizon_color


func _on_scene_changed() -> void:
	shader = get_tree().current_scene.get_node_or_null("Shader")
