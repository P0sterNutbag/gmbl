extends Control

@export var potential_items: Array[SpawnChanceResource]
@export var target: Node3D
var mine_speed: float = 10
const ALERT = preload("res://Scenes/Overworld/UI/alert.tscn")
@onready var button_prompt: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer
@onready var inventory: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/VBoxContainer
@onready var progress_bar: ProgressBar = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/VBoxContainer/ProgressBar


func _process(delta: float) -> void:
	if !visible:
		return
	global_position = get_viewport().get_camera_3d().unproject_position(target.global_transform.origin)
	if Input.is_action_just_pressed("select"):
		inventory.visible = ! inventory.visible
		button_prompt.visible = !inventory.visible
	if inventory.visible:
		progress_bar.value += mine_speed * delta
		if progress_bar.value >= progress_bar.max_value:
			find_item()
			progress_bar.value = 0


func find_item() -> void:
	var item = potential_items[Globals.get_weighted_index(potential_items)].object_to_spawn
	PlayerStats.items.append(item)
	var inst = ALERT.instantiate()
	Globals.ui.add_child(inst)
	inst.text = "+1 " + item.title


func _on_visibility_changed() -> void:
	if is_node_ready():
		inventory.hide()
		button_prompt.show()
