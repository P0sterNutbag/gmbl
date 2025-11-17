extends Resource
class_name Quest

@export var type: String
@export var title: String
@export var description: String
@export var location: String
@export var return_location: String
@export var reward: ItemSlot
@export var completed: bool
var target_node: Node3D
