extends SubViewport

@onready var enemy_model: Node3D = $Offset/EnemyModel
@onready var shopkeeper_portrait: SubViewport = $"../ShopkeeperPortrait"


func get_bounty_texture(style_data: NpcStyle) -> Image:
	enemy_model.set_materials(style_data)
	await RenderingServer.frame_post_draw
	var image = get_texture().get_image()
	return image
