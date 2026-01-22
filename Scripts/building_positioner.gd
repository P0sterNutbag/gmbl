extends MeshInstance3D


func _ready() -> void:
	var aabb = get_aabb()
	var local_corners = [
		Vector3(aabb.position.x, aabb.position.y, aabb.position.z),
		Vector3(aabb.position.x + aabb.size.x, aabb.position.y, aabb.position.z),
		Vector3(aabb.position.x, aabb.position.y, aabb.position.z + aabb.size.z),
		Vector3(aabb.position.x + aabb.size.x, aabb.position.y, aabb.position.z + aabb.size.z),
	]
	var largest_gap := 0.0
	for i in local_corners:
		var gap = Globals.get_heightmap_position(global_position + i) - global_position.y
		if gap > largest_gap:
			largest_gap = gap
	global_position.y -= largest_gap
