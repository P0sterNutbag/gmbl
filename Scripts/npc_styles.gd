extends Resource
class_name NpcStyle

@export var skin_colors: Array[Color]
@export var hair_colors: Array[Color]
@export var hair_styles: Array[Texture]
@export var faces: Array[Texture]
@export var shirts: Array[Texture]
@export var pants_colors: Array[Color]
@export var shoe_colors: Array[Color]


func generate_style() -> NpcStyle:
	var new_style = NpcStyle.new()
	var skin_color = skin_colors[randi() % skin_colors.size()]
	new_style.skin_colors.append(skin_color)
	var hair_color = hair_colors[randi() % hair_colors.size()]
	new_style.hair_colors.append(hair_color)
	var hair_style = hair_styles[randi() % hair_styles.size()]
	new_style.hair_styles.append(hair_style)
	var face = faces[randi() % faces.size()]
	new_style.faces.append(face)
	var shirt = shirts[randi() % shirts.size()]
	new_style.shirts.append(shirt)
	var pants_color = pants_colors[randi() % pants_colors.size()]
	new_style.pants_colors.append(pants_color)
	var shoe_color = shoe_colors[randi() % shoe_colors.size()]
	new_style.shoe_colors.append(shoe_color)
	return new_style
