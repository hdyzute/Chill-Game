extends CanvasLayer
class_name CombatManager

@export var skill_heal_multiplier: float = 2.0

enum CombatState { IDLE, ATTACKING, DEAD }

signal log_message(msg: String)

var enemy_data: MonsterData
var enemy_hp: int

var attack_timer: Timer

@onready var log_label: Label = $Panel/VBoxContainer/LogLabel
@onready var pet_hp_bar: ProgressBar = $Panel/VBoxContainer/PetHPBar
@onready var enemy_hp_bar: ProgressBar = $Panel/VBoxContainer/EnemyHPBar
@onready var skill_button: Button = $Panel/VBoxContainer/SkillButton
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton

# Pet temporary HP for this battle
var pet_current_hp: int

func _ready() -> void:
	if skill_button:
		skill_button.pressed.connect(use_player_skill)
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
		close_button.hide()

func setup_combat(wild_enemy: MonsterData) -> void:
	enemy_data = wild_enemy
	enemy_hp = enemy_data.base_hp
	pet_current_hp = GameManager.get_pet_total_hp()
	
	if pet_hp_bar:
		pet_hp_bar.max_value = pet_current_hp
		pet_hp_bar.value = pet_current_hp
		
	if enemy_hp_bar:
		enemy_hp_bar.max_value = enemy_hp
		enemy_hp_bar.value = enemy_hp
	
	add_log("Gặp phải " + enemy_data.monster_name + "!")
	if skill_button:
		skill_button.hide()
	
	attack_timer = Timer.new()
	attack_timer.wait_time = 1.0 # 1 attack per sec
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)
	attack_timer.start()

func add_log(msg: String) -> void:
	print(msg)
	if log_label:
		# Keep log short
		var lines = log_label.text.split("\n")
		if lines.size() > 10:
			lines.remove_at(0)
			log_label.text = "\n".join(lines)
		log_label.text += msg + "\n"

func _on_attack_timer_timeout() -> void:
	# Pet attacks enemy
	var pet_dmg = GameManager.get_pet_total_atk() - enemy_data.base_def
	if pet_dmg < 1: pet_dmg = 1
	enemy_hp -= pet_dmg
	if enemy_hp_bar: enemy_hp_bar.value = enemy_hp
	add_log("Pet đánh " + str(pet_dmg) + " sát thương.")
	
	if enemy_hp <= 0:
		_end_combat(true)
		return
		
	# Enemy attacks pet
	var enemy_dmg = enemy_data.base_atk - GameManager.get_pet_total_def()
	if enemy_dmg < 1: enemy_dmg = 1
	pet_current_hp -= enemy_dmg
	if pet_hp_bar: pet_hp_bar.value = pet_current_hp
	add_log("Quái phản công " + str(enemy_dmg) + " sát thương.")
	
	if pet_current_hp <= 0:
		_end_combat(false)

func use_player_skill() -> void:
	pass

func _end_combat(victory: bool, captured: bool = false) -> void:
	attack_timer.stop()
	if skill_button: skill_button.hide()
	
	if victory:
		GameManager.battles_fought += 1
		add_log("Chiến thắng!")
		var exp_gained = enemy_data.exp_reward if enemy_data else 50
		GameManager.add_exp(exp_gained)
		add_log("Nhận được " + str(exp_gained) + " EXP")
		
		# Drop item
		var drop_rate = enemy_data.drop_rate_evo_stone if enemy_data else 0.5
		if randf() < drop_rate:
			var drop_item = "evo_stone"
			GameManager.player_data.add_item(drop_item)
			GameManager.evo_stones_dropped += 1
			add_log("Nhặt được: " + drop_item)
			
		var gold_dropped = 100 if (enemy_data and enemy_data.is_boss) else randi_range(10, 30)
		GameManager.player_data.gold += gold_dropped
		add_log("Nhận được " + str(gold_dropped) + " Vàng")
	else:
		add_log("Thất bại! Sủng thú kiệt sức.")
		
	if close_button:
		close_button.show()

func _on_close_pressed() -> void:
	var victory = (enemy_hp <= 0)
	GameManager.end_combat(victory)
	queue_free()
