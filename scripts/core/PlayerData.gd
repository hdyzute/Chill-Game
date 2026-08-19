class_name PlayerData
extends Resource

signal stats_changed
signal leveled_up(new_level: int)
signal exp_gained(amount: int)
signal equipment_changed

@export var level: int = 1
@export var exp: int = 0
@export var exp_to_next_level: int = 100
@export var exp_curve_multiplier: float = 1.2
@export var gold: int = 50

@export var base_hp: int = 50
@export var base_atk: int = 5
@export var base_def: int = 3
@export var hp_growth_per_level: int = 3
@export var atk_growth_per_level: int = 1
@export var def_growth_per_level: int = 1

@export var talent_id: String
@export var equipped_weapon_id: String
@export var equipped_armor_id: String

@export var pet_roster: Array[MonsterInstanceData] = []
@export var active_pet_index: int = 0
@export var last_shop_refresh_date: Dictionary = {}
@export var shop_daily_pets: Array[MonsterInstanceData] = []

# For storing equipped item data directly or via ID lookup
var equipped_weapon: EquipmentData = null
var equipped_armor: EquipmentData = null
var talent: TalentData = null

# In MVP, an array of item IDs for inventory
@export var inventory: Array[String] = []

func add_exp(amount: int) -> void:
	exp += amount
	exp_gained.emit(amount)
	check_level_up()
	stats_changed.emit()

func check_level_up() -> void:
	while exp >= exp_to_next_level:
		exp -= exp_to_next_level
		level += 1
		exp_to_next_level = int(exp_to_next_level * exp_curve_multiplier) # Simple curve
		leveled_up.emit(level)
		if talent and talent.stat_type == "heal_on_levelup":
			# Signal or handle healing here, in MVP we might just emit
			pass

func get_total_hp() -> int:
	var total = base_hp + (hp_growth_per_level * (level - 1))
	if equipped_armor: total += equipped_armor.hp_bonus
	if equipped_weapon: total += equipped_weapon.hp_bonus
	if talent and talent.stat_type == "hp_percent":
		total = int(total * (1.0 + talent.value))
	return total

func get_total_atk() -> int:
	var total = base_atk + (atk_growth_per_level * (level - 1))
	if equipped_weapon: total += equipped_weapon.atk_bonus
	if equipped_armor: total += equipped_armor.atk_bonus
	if talent and talent.stat_type == "atk_percent":
		total = int(total * (1.0 + talent.value))
	return total

func get_total_def() -> int:
	var total = base_def + (def_growth_per_level * (level - 1))
	if equipped_armor: total += equipped_armor.def_bonus
	if equipped_weapon: total += equipped_weapon.def_bonus
	return total

func equip(item: EquipmentData) -> void:
	if item.slot_type == "weapon":
		equipped_weapon = item
		equipped_weapon_id = item.equip_id
	elif item.slot_type == "armor":
		equipped_armor = item
		equipped_armor_id = item.equip_id
	equipment_changed.emit()
	stats_changed.emit()

func has_item(item_id: String) -> bool:
	return inventory.has(item_id)

func add_item(item_id: String) -> void:
	inventory.append(item_id)
	stats_changed.emit()

func remove_item(item_id: String) -> void:
	if inventory.has(item_id):
		inventory.erase(item_id)
		stats_changed.emit()
