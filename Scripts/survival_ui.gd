extends CanvasLayer

var compass_object: Node3D
var quest_marker_texture = preload("res://Art/Textures/target.png")
var quests: Array[Quest]
@onready var compass: ColorRect = $TopCenter/Compass/ColorRect
@onready var markers: Control = $TopCenter/Compass/Markers
@onready var compass_holder: Control = $TopCenter/Compass
@onready var player_inventory_holder: HBoxContainer = $PlayerInventory
@onready var transfer_inventory_holder: HBoxContainer = $TransferInventory
@onready var player_transfer_inventory: InventoryUI = %Inventory
@onready var loot_transfer_inventory: InventoryUI = %Inventory2
@onready var journal: HBoxContainer = $Journal


func _enter_tree() -> void:
	Globals.survival_ui = self
	await get_tree().process_frame
	add_quest_markers()
	if get_tree().current_scene.name == "Overworld":
		compass_object = Globals.player.get_node_or_null("CameraAnchor")
	else:
		compass_object = Globals.player


#func _ready() -> void:
	#for child in get_children():
		#child.hide()


func _process(_delta: float) -> void:
	# opening things
	if Input.is_action_just_pressed("inventory"):
		if !player_inventory_holder.visible:
			open_menu(player_inventory_holder)
		else:
			close_menu(player_inventory_holder)
	if Input.is_action_just_pressed("journal"):
		if journal.visible:
			close_menu(journal)
		else:
			open_menu(journal, PlayerStats.quests)
	
	# compass
	var compass_item = PlayerStats.find_item("compass")
	if compass_item and compass_item.equipped:
		compass_holder.visible = true
		# compass movement
		var cam_rot = rad_to_deg(compass_object.rotation.y)
		compass.position.x = compass.size.x * ((cam_rot / 360.0) + 0.5) - compass.size.x - 70
		# Position quest marker
		if get_tree().current_scene == Globals.overworld:
			quests = PlayerStats.quests
		else:
			quests = PlayerStats.quests.filter(func(i): 
				if i.completed:
					return false
				var quest_location = i.location
				var encounter_location = Globals.overworld.current_encounter.get_parent().title
				return quest_location == encounter_location)
		for i in quests.size():
			if i > quests.size():
				markers.get_child(i).queue_free()
				return
			var quest = quests[i]
			var children = markers.get_child_count()
			if children <= i:
				create_quest_marker()
			var quest_marker = markers.get_child(i)
			if quest.completed and get_tree().current_scene != Globals.overworld:
				quest_marker.queue_free()
				continue
			var quest_object = null
			if get_tree().current_scene == Globals.overworld:
				for location in get_tree().get_nodes_in_group("location"):
					if quest.location.to_lower() == location.get_parent().title.to_lower():
						quest_object = location
			else:
				quest_object = quest.target_node
			var player_forward = -compass_object.global_transform.basis.z.normalized()
			player_forward.y = 0
			var to_quest = (quest_object.global_transform.origin - compass_object.global_transform.origin).normalized()
			to_quest.y = 0
			var dot_product = clamp(player_forward.dot(to_quest), -1.0, 1.0)
			var cross = -player_forward.cross(to_quest).y  # positive = to the right, negative = to the left
			var angle = atan2(cross, dot_product)
			var angle_deg = rad_to_deg(angle)
			var fov = 90.0  # adjust as needed
			var normalized = clamp(angle_deg / (fov / 2.0), -1.0, 1.0)
			var half_width = compass_holder.size.x / 2.0
			quest_marker.position.x = half_width + (normalized * half_width) - 12
			quest_marker.position.x = clamp(quest_marker.position.x, -12, compass_holder.size.x - 12)
	else:
		compass_holder.visible = false
	
	# open pause menu
	#if Input.is_action_just_pressed("ui_cancel"):
		#if PlayerStats.state != PlayerStats.states.pause:
			#Globals.pause_game()

func add_quest_markers():
	#quests.clear()
	for child in markers.get_children():
		child.queue_free()
	quests = PlayerStats.quests.filter(func(i): 
		var quest_location = i.location
		var encounter_location = Globals.overworld.current_encounter.get_parent().title
		return quest_location == encounter_location)
	for quest in quests:
		create_quest_marker()


func create_quest_marker():
	var inst = TextureRect.new()
	inst.texture = quest_marker_texture
	inst.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	inst.size = Vector2.ONE * 24
	inst.position.y = 11
	get_node("TopCenter/Compass/Markers").add_child(inst)


func open_menu(menu: Control, array: Array = []) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	menu.show()
	if menu is MenuList:
		menu.open(array)
	PlayerStats.change_state(PlayerStats.states.pause)


func close_menu(menu: Control) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	menu.hide()
	PlayerStats.change_state(PlayerStats.states.walk)


func loot(target) -> void:
	player_transfer_inventory.mode = player_transfer_inventory.modes.loot
	loot_transfer_inventory.mode = loot_transfer_inventory.modes.loot
	player_transfer_inventory.target2 = target
	loot_transfer_inventory.target = target
	loot_transfer_inventory.target2 = PlayerStats
	loot_transfer_inventory.grab_focus()
	player_transfer_inventory.show_price = false
	loot_transfer_inventory.show_price = false
	open_menu(transfer_inventory_holder)
