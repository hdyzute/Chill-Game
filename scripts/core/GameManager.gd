extends Node

signal pet_evolved

@export_group("Realtime Combat Balance")
@export var is_realtime_combat: bool = true
@export var realtime_hp_multiplier: float = 10.0
@export var kheuoc_atk_multiplier: float = 3.0
@export var kheuoc_def_multiplier: float = 2.0
@export var kheuoc_cooldown: float = 8.0
@export var iframe_duration: float = 1.0
@export var enemy_atk_divisor: float = 4.0
@export var boss_knockback_multiplier: float = 0.15

var player_data: PlayerData

# For combat tracking
@export var pet_exp_curve_multiplier: float = 1.5

# Playtest Metrics
var play_time: float = 0.0
var battles_fought: int = 0
var evo_stones_dropped: int = 0
var time_to_first_evo: float = -1.0
var realtime_damage_taken_last: int = 0
var iframe_triggered_count: int = 0
var kheuoc_damage_last: int = 0

var debug_scene = preload("res://scenes/ui/PlaytestDebug.tscn")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	player_data = PlayerData.new()
	var dbg = debug_scene.instantiate()
	add_child(dbg)
	player_data.leveled_up.connect(func(_lv): save_game())

const SAVE_PATH = "user://save_game.tres"

func has_save_file() -> bool:
	return ResourceLoader.exists(SAVE_PATH)

func save_game() -> void:
	if not player_data: return
	var save = SaveData.new()
	save.player_data = player_data
	save.battles_fought = battles_fought
	save.evo_stones_dropped = evo_stones_dropped
	save.play_time = play_time
	
	var err = ResourceSaver.save(save, SAVE_PATH)
	if err == OK:
		print("Auto-saved game to ", SAVE_PATH)
	else:
		print("Lỗi lưu game: ", err)

func load_game() -> bool:
	if has_save_file():
		var save = ResourceLoader.load(SAVE_PATH) as SaveData
		if save and save.player_data:
			if save.player_data.pet_roster.is_empty():
				print("Phát hiện dữ liệu cũ không tương thích, đã đặt lại tiến trình")
				return false
			player_data = save.player_data
			battles_fought = save.battles_fought
			evo_stones_dropped = save.evo_stones_dropped
			play_time = save.play_time
			
			if not player_data.leveled_up.is_connected(save_game):
				player_data.leveled_up.connect(func(_lv): save_game())
			print("Loaded game from ", SAVE_PATH)
			return true
	return false

func _process(delta: float) -> void:
	play_time += delta

func set_starting_talent(talent: TalentData) -> void:
	player_data.talent = talent
	player_data.talent_id = talent.talent_id
	player_data.stats_changed.emit()

func get_active_pet() -> MonsterInstanceData:
	if not player_data or player_data.pet_roster.is_empty():
		return null
	var idx = player_data.active_pet_index
	if idx >= 0 and idx < player_data.pet_roster.size():
		return player_data.pet_roster[idx]
	return null

func set_starting_pet(pet_data: MonsterData) -> void:
	var new_inst = MonsterInstanceData.new()
	new_inst.pet_data = pet_data.duplicate(true)
	player_data.pet_roster.append(new_inst)
	player_data.active_pet_index = player_data.pet_roster.size() - 1

func can_evolve() -> bool:
	var active = get_active_pet()
	if not active or not active.pet_data or active.pet_data.evolves_into == "":
		return false
	var has_level = player_data.level >= active.pet_data.evolution_player_level_required
	var has_item = player_data.has_item(active.pet_data.evolution_item_id)
	return has_level and has_item

func evolve_pet() -> void:
	if can_evolve():
		if time_to_first_evo < 0:
			time_to_first_evo = play_time
			
		var active = get_active_pet()
		var current_pet_data = active.pet_data
		player_data.remove_item(current_pet_data.evolution_item_id)
		
		var next_pet_id = current_pet_data.evolves_into
		var next_pet_data = MonsterDatabase.get_monster(next_pet_id)
		if next_pet_data:
			var new_data = next_pet_data.duplicate(true)
			for eff in current_pet_data.on_hit_effects:
				var already_has = false
				for new_eff in new_data.on_hit_effects:
					if new_eff.effect_id == eff.effect_id:
						already_has = true
						break
				if not already_has:
					new_data.on_hit_effects.append(eff.duplicate(true))
					
			if current_pet_data.element != "" and new_data.element != "" and current_pet_data.element != new_data.element:
				new_data.element = current_pet_data.element + " + " + new_data.element
			elif current_pet_data.element != "" and new_data.element == "":
				new_data.element = current_pet_data.element
				
			active.pet_data = new_data
			pet_evolved.emit()
			save_game()
		else:
			print("Error: Evolution data not found!")

func add_exp(amount: int) -> void:
	player_data.add_exp(amount)
	var active = get_active_pet()
	if active:
		var old_level = active.level
		active.exp += amount
		while active.exp >= active.exp_to_next:
			active.exp -= active.exp_to_next
			active.level += 1
			active.exp_to_next = int(active.exp_to_next * pet_exp_curve_multiplier)
		
		if active.level > old_level:
			save_game()
	player_data.stats_changed.emit()

func get_pet_total_hp() -> int:
	var active = get_active_pet()
	return active.get_total_hp() if active else 1

func get_pet_total_atk() -> int:
	var active = get_active_pet()
	return active.get_total_atk() if active else 1

func get_pet_total_def() -> int:
	var active = get_active_pet()
	return active.get_total_def() if active else 1

var combat_scene_prefab = preload("res://scenes/combat.tscn")
var current_wild_enemy_node: Node2D

func start_combat(wild_enemy_node: Node2D, enemy_data: MonsterData) -> void:
	if is_realtime_combat: return
	current_wild_enemy_node = wild_enemy_node
	get_tree().paused = true
	var combat_inst = combat_scene_prefab.instantiate()
	get_tree().current_scene.add_child(combat_inst)
	if combat_inst.has_method("setup_combat"):
		combat_inst.setup_combat(enemy_data)

func end_combat(victory: bool) -> void:
	get_tree().paused = false
	if victory and is_instance_valid(current_wild_enemy_node):
		current_wild_enemy_node.queue_free()
	current_wild_enemy_node = null
