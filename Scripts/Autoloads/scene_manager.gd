extends Node

@onready var scene_transition: Control = $SceneTransition
var next_scene
var remove_from_tree: bool


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
	else:
		if next_scene is String:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(next_scene))
		elif next_scene is Node3D:
			get_tree().root.remove_child(get_tree().current_scene)
			get_tree().root.add_child(next_scene)
			get_tree().current_scene = next_scene
	scene_transition.transition_out()
	get_tree().paused = false


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
