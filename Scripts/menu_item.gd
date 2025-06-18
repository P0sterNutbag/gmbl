extends Control

var title: String: 
	set(value):
		title = value
		$Label2.text = value
var selected: bool:
	set(value):
		selected = value
		$Label.visible = value
var amount: int = 1:
	set(value):
		amount = value
		if amount <= 1: 
			$Label3.text = "" 
			return
		$Label3.text = "(" + str(value) + ")"
var equipped: bool:
	set(value):
		equipped = value
		if equipped:
			$Label3.text = "*" 
		else:
			$Label3.text = "" 
var item: Item
signal pressed


func _enter_tree() -> void:
	selected = false


func _process(delta: float) -> void:
	# select
	if Input.is_action_just_pressed("interact") and selected:
		pressed.emit()
	# show equipped
	if item and item is Equipment:
		equipped = item.equipped
