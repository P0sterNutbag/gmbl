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
		if Globals.ui.inventory_container.visible:
			var menu = Globals.ui.inventory_container.get_child(0)
			var in_menu = (get_global_mouse_position().x > menu.global_position.x and 
			get_global_mouse_position().x < menu.global_position.x + menu.size.x and 
			get_global_mouse_position().y > menu.global_position.y and 
			get_global_mouse_position().y < menu.global_position.y + menu.size.y)
			if !in_menu:
				if resource.physical_item != null:
					create_physical_item(resource.physical_item)
					if resource == PlayerStats.gun:
						Globals.player.gun.visible = false
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
				if resource.physical_item != null:
					create_physical_item(resource.physical_item)
					if resource == PlayerStats.gun:
						Globals.player.gun.visible = false
				delete.emit()
				queue_free()
			elif (in_menu2 and owner == menu_1) or (in_menu1 and owner == menu_2):
				transfer.emit()


func create_physical_item(physical_item: PackedScene) -> void:
	var inst: RigidBody3D = physical_item.instantiate()
	get_tree().current_scene.add_child.call_deferred(inst)
	inst.set_deferred("global_position", Globals.player.global_position + Vector3.UP * 1.5)
	inst.apply_impulse.call_deferred(-Globals.player.basis.z * 5)
	inst.apply_torque_impulse.call_deferred(Vector3(randf_range(-0.1, 0.1), randf_range(-5, 5), randf_range(-0.1, 0.1)))
	inst.item = resource
	#if inst.item is EquipmentGun:
		#inst.item.gun_stats = resource.gun_stats
