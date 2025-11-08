extends Button

var amount: int = 1:
	set(value):
		amount = value
		text = text.rstrip("(1234567890)")
		if amount <= 1: 
			return
		text += "(" + str(value) + ")"
var equipped: bool:
	set(value):
		equipped = value
		text = text.rstrip("*")
		if equipped:
			text += "*"
var price: int:
	set(value):
		price = value
		price_label.text = ""
		if value > 0:
			price_label.text += "$" + str(price)
var resource: Resource
var icon_texture: Texture2D
var can_press: bool
var moveable: bool
var can_grab: bool
var follow_mouse: bool
var pouch = preload("res://Scenes/Items/pouch.tscn")
@onready var price_label: Label = %Price
signal delete
signal transfer


func _ready() -> void:
	icon_texture = icon
	icon = null
	await get_tree().create_timer(0.1).timeout
	can_press = true


func _process(_delta: float) -> void:
	# select
	if Input.is_action_just_pressed("interact") and has_focus() and can_press:
		pressed.emit()
	# show equipped
	if resource and resource is Equipment:
		equipped = resource.equipped
	# follow mouse
	if follow_mouse:
		global_position = get_global_mouse_position()


func _on_focus_entered() -> void:
	icon = icon_texture


func _on_focus_exited() -> void:
	icon = null


func _on_mouse_entered() -> void:
	grab_focus()


func _on_mouse_exited() -> void:
	release_focus()


func _on_gui_input(event: InputEvent) -> void:
	if !moveable:
		return
	if event is InputEventMouseButton and event.pressed:
		can_grab = true
	if event is InputEventMouseMotion and can_grab and !follow_mouse:
		follow_mouse = true
		#get_tree().current_scene.add_child(self)
	if event is InputEventMouseButton and event.is_released():
		if !follow_mouse:
			can_grab = false
			return
		follow_mouse = false
		can_grab = false
		# determine amount to move
		var amount_to_move = 1
		if Input.is_action_just_pressed("shift"):
			amount_to_move = resource.amount
		if owner.visible:
			var menu = owner.get_child(0)
			var in_menu = (get_global_mouse_position().x > menu.global_position.x and 
			get_global_mouse_position().x < menu.global_position.x + menu.size.x and 
			get_global_mouse_position().y > menu.global_position.y and 
			get_global_mouse_position().y < menu.global_position.y + menu.size.y)
			if !in_menu:
				create_physical_item(resource.physical_item)
				if resource == PlayerStats.gun:
					Globals.player.gun.visible = false
				amount -= amount_to_move
				resource.amount -= amount_to_move
				if amount <= 0:
					delete.emit()
					queue_free()
		elif Globals.ui.inventory_container2.visible:
			var menu_1 = Globals.ui.inventory_container2.get_child(0)
			var in_menu1 = (get_global_mouse_position().x > menu_1.global_position.x and 
			get_global_mouse_position().x < menu_1.global_position.x + menu_1.size.x and 
			get_global_mouse_position().y > menu_1.global_position.y and 
			get_global_mouse_position().y < menu_1.global_position.y + menu_1.size.y)
			var menu_2 = Globals.ui.inventory_container2.get_child(1)
			var in_menu2 = (get_global_mouse_position().x > menu_2.global_position.x and 
			get_global_mouse_position().x < menu_2.global_position.x + menu_2.size.x and 
			get_global_mouse_position().y > menu_2.global_position.y and 
			get_global_mouse_position().y < menu_2.global_position.y + menu_2.size.y)
			if !in_menu1 and !in_menu2:
				create_physical_item(resource.physical_item)
				if resource == PlayerStats.gun:
					Globals.player.gun.visible = false
				amount -= amount_to_move
				resource.amount -= amount_to_move
				if amount <= 0:
					delete.emit()
					queue_free()
			elif (in_menu2 and owner == menu_1) or (in_menu1 and owner == menu_2):
				transfer.emit()


func create_physical_item(physical_item: PackedScene = null) -> void:
	if physical_item == null or get_tree().current_scene == Globals.overworld:
		# determine amount to move
		var amount_to_move = 1
		if Input.is_action_just_pressed("shift"):
			amount_to_move = resource.amount
		var new_item = resource.duplicate()
		new_item.amount = amount_to_move
		# create pouch or move to pouch
		var pouches: Array = Globals.player.loot_area.get_overlapping_areas()
		pouches.filter(func(i): return i.is_in_group("pouches"))
		if pouches.size() > 0:
			pouches[0].items.append(new_item)
			return
		var p = pouch.instantiate()
		get_tree().current_scene.add_child(p)
		var offset = -Globals.player.basis.z
		if get_tree().current_scene == Globals.overworld:
			offset = -Globals.player.model.basis.z
		p.global_position = Globals.player.global_position + offset
		p.global_position.y = Globals.get_heightmap_position(p.global_position)
		p.items.append(new_item)
		return
	var inst: RigidBody3D = physical_item.instantiate()
	get_tree().current_scene.add_child.call_deferred(inst)
	inst.set_deferred("global_position", Globals.player.global_position + Vector3.UP * 1.5)
	inst.apply_impulse.call_deferred(-Globals.player.basis.z * 5)
	inst.apply_torque_impulse.call_deferred(Vector3(randf_range(-0.1, 0.1), randf_range(-5, 5), randf_range(-0.1, 0.1)))
	inst.item = resource
	#if inst.item is EquipmentGun:
		#inst.item.gun_stats = resource.gun_stats
