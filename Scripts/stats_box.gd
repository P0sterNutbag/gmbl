extends PanelContainer

@onready var toughness_stat: Button = $MarginContainer/VBoxContainer/Toughness
@onready var strength_stat: Button = $MarginContainer/VBoxContainer/Strength
@onready var speed_stat: Button = $MarginContainer/VBoxContainer/Speed
@onready var guns_stat: Button = $MarginContainer/VBoxContainer/Guns
@onready var stealth: Button = $MarginContainer/VBoxContainer/Stealth
@onready var skill_points_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/StatPoints
@onready var vbox_container: VBoxContainer = $MarginContainer/VBoxContainer
signal skill_changed(skill_name: String)


func _ready() -> void:
	setup()
	skill_changed.connect(PlayerStats._on_skill_changed)


func setup() -> void:
	skill_points_label.text = "Points Left: " + str(int(PlayerStats.skill_points))
	if PlayerStats.skill_points == 0:
		skill_points_label.hide()
	else:
		skill_points_label.show()
	for i in vbox_container.get_child_count():
		var child = vbox_container.get_child(i)
		if child is NumberScrollButton:
			child.set_value(PlayerStats.skills.get(child.stat_name))
			child.min_value = child.value
			if PlayerStats.skill_points == 0:
				child.right_button.hide()
				child.left_button.hide()


func change_stat(node: Control, value: float, changed_by: float) -> void:
	PlayerStats.skills.set(node.stat_name, value)
	PlayerStats.skill_points = clamp(PlayerStats.skill_points - changed_by, 0, 100)
	skill_points_label.text = "Points Left: " + str(int(PlayerStats.skill_points))
	skill_changed.emit(node.stat_name)
	#if PlayerStats.skill_points > 0 or changed_by < 0:
		#PlayerStats.skills.set(node.stat_name, value)
		#PlayerStats.skill_points = clamp(PlayerStats.skill_points - changed_by, 0, 100)
		#skill_points_label.text = "Points Left: " + str(int(PlayerStats.skill_points))
		#skill_changed.emit(node.stat_name)
	#else:
		#PlayerStats.skill_points += changed_by
		#node.set_value(value - changed_by)
		#node.value_label.text = str(int(node.value))
	if PlayerStats.skill_points <= 0:
		for child in vbox_container.get_children():
			if child is NumberScrollButton:
				child.right_button.hide()
	else:
		for child in vbox_container.get_children():
			if child is NumberScrollButton:
				child.show_buttons()


func _on_toughness_value_changed(value: float, changed_by: float) -> void:
	change_stat(toughness_stat, value, changed_by)


func _on_strength_value_changed(value: float, changed_by: float) -> void:
	change_stat(strength_stat, value, changed_by)


func _on_speed_value_changed(value: float, changed_by: float) -> void:
	change_stat(speed_stat, value, changed_by)


func _on_handguns_value_changed(value: float, changed_by: float) -> void:
	change_stat(guns_stat, value, changed_by)


func _on_stealth_value_changed(value: float, changed_by: float) -> void:
	change_stat(stealth, value, changed_by)


func _on_visibility_changed() -> void:
	if !is_node_ready():
		await ready
	if visible:
		setup()
