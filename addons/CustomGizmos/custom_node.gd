@tool
extends Node
class_name CustomNode

func _ready():
    if not Engine.is_editor_hint():
        return
    var body := StaticBody3D.new()
    body.input_ray_pickable = true
    var shape := CollisionShape3D.new()
    shape.shape = SphereShape3D.new()
    shape.shape.radius = 1
    add_child(body)
    body.add_child(shape)
    body.owner = get_tree().edited_scene_root
    shape.owner = get_tree().edited_scene_root
