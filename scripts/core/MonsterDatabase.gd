extends Node

var monsters: Dictionary = {}

func _ready() -> void:
	load_all_monsters()

func load_all_monsters() -> void:
	var path = "res://resources/monsters/"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				var clean_name = file_name.trim_suffix(".remap")
				if clean_name.ends_with(".tres") or clean_name.ends_with(".res"):
					var res = ResourceLoader.load(path + clean_name) as MonsterData
					if res and res.monster_id != "":
						monsters[res.monster_id] = res
			file_name = dir.get_next()

func get_monster(id: String) -> MonsterData:
	if monsters.has(id):
		return monsters[id]
	return null
