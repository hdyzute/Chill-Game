extends Node

@export var starting_pet: MonsterData
@export var starting_talent: TalentData

func _ready() -> void:
	if GameManager.has_save_file() and GameManager.load_game():
		pass # Đã load thành công
			
	# Chuyển sang Lobby (Sảnh Chờ)
	get_tree().change_scene_to_file("res://scenes/ui/Lobby.tscn")
