extends Node

@onready var scene_transition: Control = $SceneTransition
@onready var animation_player: AnimationPlayer = $SceneTransition/AnimationPlayer
var next_scene
var remove_from_tree: bool
var load_on_enter: bool
var save_on_enter: bool
signal scene_changed
signal new_game_start
signal scene_leaving


func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	set_process(false)


func start_scene_transition(scene, remove_current: bool = false) -> void:
	get_tree().current_scene.set_deferred("process_mode", PROCESS_MODE_DISABLED)
	scene_transition.transition_in()
	next_scene = scene
	remove_from_tree = remove_current


func start_encounter_transition(scene) -> void:
	get_tree().current_scene.set_deferred("process_mode", PROCESS_MODE_DISABLED)
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(Globals.player.camera, "position:z", 2, 1)
	tween.tween_callback(start_scene_transition.bind(scene, true))


func change_scene() -> void:
	scene_leaving.emit()
	if remove_from_tree:
		get_tree().root.remove_child(get_tree().current_scene)
		var inst = load(next_scene).instantiate()
		get_tree().root.add_child(inst)
		get_tree().current_scene = inst
	else:
		if next_scene is String:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(next_scene))
			if next_scene == "res://Scenes/UI/Levels/character_creation.tscn":
				new_game_start.emit()
		elif next_scene is Node3D:
			get_tree().change_scene_to_node(next_scene)
			#get_tree().current_scene = next_scene
	scene_transition.transition_out()
	UiController.reset_list()
	get_tree().paused = false
	await get_tree().process_frame
	scene_changed.emit()
	if load_on_enter:
		load_on_enter = false
		PlayerStats.state = PlayerStats.states.walk
		SaveController.load_data_from_file()
	if save_on_enter:
		save_on_enter = false
		SaveController.save_data_to_file()


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
