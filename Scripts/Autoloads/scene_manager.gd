extends Node

@onready var scene_transition: Control = $SceneTransition
@onready var animation_player: AnimationPlayer = $SceneTransition/AnimationPlayer
var next_scene
var remove_from_tree: bool
var load_on_enter: bool


func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	set_process(false)


func start_scene_transition(scene, remove_current: bool = false) -> void:
	get_tree().current_scene.set_deferred("process_mode", PROCESS_MODE_DISABLED)
	scene_transition.transition_in()
	next_scene = scene
	remove_from_tree = remove_current


func change_scene() -> void:
	if remove_from_tree:
		get_tree().root.remove_child(get_tree().current_scene)
		var inst = load(next_scene).instantiate()
		get_tree().root.add_child(inst)
		get_tree().current_scene = inst
		MusicManager.on_scene_transition(next_scene)
	else:
		if next_scene is String:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(next_scene))
			MusicManager.on_scene_transition(next_scene)
		elif next_scene is Node3D:
			get_tree().root.remove_child(get_tree().current_scene)
			get_tree().root.add_child(next_scene)
			get_tree().current_scene = next_scene
			MusicManager.on_scene_transition(next_scene.name)
	scene_transition.transition_out()
	get_tree().paused = false
	await get_tree().process_frame
	if load_on_enter:
		load_on_enter = false
		PlayerStats.state = PlayerStats.states.walk
		SaveController.load_data_from_file()



func start_load() -> void:
	if next_scene is String:
		ResourceLoader.load_threaded_request(next_scene)
		set_process(true)
	else:
		change_scene()


func _process(_delta):
	var load_status = ResourceLoader.load_threaded_get_status(next_scene)
	match load_status:
		ResourceLoader.THREAD_LOAD_LOADED:
			change_scene()
			set_process(false)
		ResourceLoader.THREAD_LOAD_FAILED:
			print("THREAD_LOAD_FAILED")
