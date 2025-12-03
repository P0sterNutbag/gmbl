extends Control

@onready var timer: Timer = $Timer
@onready var label: Label = $ColorRect/Label
signal transition_in_done
signal transition_out_done


@onready var animation_player = $AnimationPlayer


func transition_in():
	animation_player.play("transition_in")


func transition_out():
	label.hide()
	animation_player.play("transition_out")


func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "transition_in":
		transition_in_done.emit()
		label.show()
		timer.start()
	elif anim_name == "transition_out":
		transition_out_done.emit()
		timer.stop()


func _on_timer_timeout() -> void:
	label.text += "*"
	if label.text == "Loading****":
		label.text = "Loading"
