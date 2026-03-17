extends PanelContainer

@onready var toughness_stat: Button = $MarginContainer/VBoxContainer/Toughness
@onready var strength_stat: Button = $MarginContainer/VBoxContainer/Strength
@onready var speed_stat: Button = $MarginContainer/VBoxContainer/Speed
@onready var handguns_stat: Button = $MarginContainer/VBoxContainer/Handguns
@onready var long_guns_stat: Button = $MarginContainer/VBoxContainer/LongGuns
@onready var stat_points_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/StatPoints
@onready var vbox_container: VBoxContainer = $MarginContainer/VBoxContainer


func _ready() -> void:
	setup()


func setup() -> void:
	stat_points_label.text = "Points Left: " + str(int(PlayerStats.stat_points))
	for i in vbox_container.get_child_count():
		var child = vbox_container.get_child(i)
		if child is NumberScrollButton:
			child.set_value(PlayerStats.stats.get(child.stat_name))
			child.min_value = child.value
			if PlayerStats.stat_points == 0:
				child.right_button.hide()
				child.left_button.hide()


func change_stat(node: Control, value: float, changed_by: float) -> void:
	if PlayerStats.stat_points > 0 or changed_by < 0:
		PlayerStats.stats.set(node.stat_name, value)
		PlayerStats.stat_points = clamp(PlayerStats.stat_points - changed_by, 0, 100)
		stat_points_label.text = "Points Left: " + str(int(PlayerStats.stat_points))
	else:
		PlayerStats.stat_points += changed_by
		node.set_value(value - changed_by)
		node.value_label.text = str(int(node.value))
	if PlayerStats.stat_points <= 0:
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
	change_stat(handguns_stat, value, changed_by)


func _on_long_guns_value_changed(value: float, changed_by: float) -> void:
	change_stat(long_guns_stat, value, changed_by)


func _on_visibility_changed() -> void:
	if !is_node_ready():
		await ready
	if visible:
		setup()
