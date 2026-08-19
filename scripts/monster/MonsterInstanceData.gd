class_name MonsterInstanceData
extends Resource

@export var pet_data: MonsterData
@export var level: int = 1
@export var exp: int = 0
@export var exp_to_next: int = 100
@export var bloodline_tier: String = "Thường"
@export var bloodline_multiplier: float = 1.0

func get_total_hp() -> int:
	if not pet_data: return 1
	var growth = int(pet_data.hp_growth_per_level * bloodline_multiplier)
	return pet_data.base_hp + (growth * (level - 1))

func get_total_atk() -> int:
	if not pet_data: return 1
	var growth = int(pet_data.atk_growth_per_level * bloodline_multiplier)
	return pet_data.base_atk + (growth * (level - 1))

func get_total_def() -> int:
	if not pet_data: return 1
	var growth = int(pet_data.def_growth_per_level * bloodline_multiplier)
	return pet_data.base_def + (growth * (level - 1))

static func generate_new(template: MonsterData) -> MonsterInstanceData:
	var inst = MonsterInstanceData.new()
	inst.pet_data = template.duplicate(true)
	
	var r = randf()
	if r < 0.03:
		inst.bloodline_tier = "Hoàn Hảo"
		inst.bloodline_multiplier = 1.5
	elif r < 0.15:
		inst.bloodline_tier = "Xuất Sắc"
		inst.bloodline_multiplier = 1.3
	elif r < 0.40:
		inst.bloodline_tier = "Tốt"
		inst.bloodline_multiplier = 1.15
	else:
		inst.bloodline_tier = "Thường"
		inst.bloodline_multiplier = 1.0
	
	return inst
