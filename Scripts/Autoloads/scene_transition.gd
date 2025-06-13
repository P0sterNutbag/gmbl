extends Control


signal transition_in_done
signal transition_out_done


@onready var animation_player = $AnimationPlayer


func transition_in():
	animation_player.play("transition_in")


func transition_out():
	animation_player.play("transition_out")


func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "transition_in":
		transition_in_done.emit()
	elif anim_name == "transition_out":
		transition_out_done.emit()
