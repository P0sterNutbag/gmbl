extends Resource
class_name Item

@export var title: String
@export var icon: Texture
@export var physical_item: PackedScene
@export var price: int
@export var description: String
@export var stackable: bool = true
@export var takes_space: bool = true
signal used_up


func on_pressed():
	pass
