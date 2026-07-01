extends Button

var npc_data: NpcData
@onready var rank_label: Label = $HBoxContainer/Label2
@onready var progress_bar: ProgressBar = $HBoxContainer/HBoxContainer/ProgressBar


func _process(_delta: float) -> void:
	if npc_data:
		text = npc_data.title
		rank_label.text = "Rank: " + npc_data.get_rank()
		progress_bar.value = npc_data.hp / npc_data.max_hp
