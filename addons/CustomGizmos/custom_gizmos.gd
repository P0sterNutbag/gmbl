extends EditorNode3DGizmoPlugin

const MyCustomNode3D = preload("res://addons/CustomGizmos/custom_node.gd")
const TARGET = preload("uid://d33611mk1jlrx")
const FACE = preload("uid://vkv3rps0wawi")
const ENEMY_SPAWN_GIZMO = preload("uid://cmisg4mqlo6xf")


func _init():
	create_material("main", Color(1,0,0))
	create_handle_material("handle")


func _get_gizmo_name():
	return "EnemySpawnPoint"


func _has_gizmo(node):
	return node is MyCustomNode3D


func _redraw(gizmo: EditorNode3DGizmo):
	gizmo.clear()
	gizmo.add_unscaled_billboard(ENEMY_SPAWN_GIZMO, 0.05)
	
	#gizmo.add_handles(PackedVector3Array(), get_material("handles", gizmo), [])




#func _get_handle_name() -> String:
	#pass


#func  _get_handle_value():
	#pass
#
#
#func _commit_handle():
	#pass
