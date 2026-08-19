extends SceneTree

func _init() -> void:
	print("--- BẮT ĐẦU TEST LỖI SHARED RESOURCE ---")
	
	# Load Quái hoang dã từ file
	var wild_monster_template = load("res://resources/monsters/thu_khoi_dau.tres") as MonsterData
	print("[Wild Monster] Số lượng effect gốc: ", wild_monster_template.on_hit_effects.size())
	
	# Khởi tạo Pet của người chơi với duplicate(true)
	var player_pet = wild_monster_template.duplicate(true)
	print("[Player Pet] Số lượng effect ban đầu: ", player_pet.on_hit_effects.size())
	
	# Cho Pet thức tỉnh (thêm 1 effect mới vào mảng)
	print(">>> Thức tỉnh Pet! Thêm hiệu ứng mới...")
	var new_effect = load("res://resources/effects/slow.tres").duplicate(true)
	player_pet.on_hit_effects.append(new_effect)
	
	# In ra kết quả
	print("[Player Pet] Số lượng effect sau khi thức tỉnh: ", player_pet.on_hit_effects.size())
	print("[Wild Monster] Số lượng effect gốc hiện tại: ", wild_monster_template.on_hit_effects.size())
	
	if wild_monster_template.on_hit_effects.size() == 1:
		print("=> TEST PASSED: Wild Monster không bị ảnh hưởng (Không bị Mutate Shared Resource).")
	else:
		print("=> TEST FAILED: Wild Monster đã bị dính effect của Pet!")
		
	quit()
