extends Control
class_name UIManager

@export var player_hp_bar: ProgressBar
@export var player_exp_bar: ProgressBar
@export var pet_hp_bar: ProgressBar
@export var pet_exp_bar: ProgressBar

@export var player_level_label: Label
@export var pet_level_label: Label
@export var inventory_label: Label

@export var leave_dungeon_button: Button

var boss_hp_bar: ProgressBar

@onready var pause_button: Button = $"../TopRight/PauseButton"
@onready var pause_menu: ColorRect = $"../PauseMenu"
@onready var resume_button: Button = $"../PauseMenu/CenterContainer/Panel/Margin/VBox/Buttons/ResumeButton"
@onready var exit_button: Button = $"../PauseMenu/CenterContainer/Panel/Margin/VBox/Buttons/ExitButton"
@onready var stats_hp: Label = $"../PauseMenu/CenterContainer/Panel/Margin/VBox/Scroll/StatsVBox/HP"
@onready var stats_atk: Label = $"../PauseMenu/CenterContainer/Panel/Margin/VBox/Scroll/StatsVBox/ATK"
@onready var stats_def: Label = $"../PauseMenu/CenterContainer/Panel/Margin/VBox/Scroll/StatsVBox/DEF"

func _ready() -> void:
	if GameManager.player_data:
		GameManager.player_data.stats_changed.connect(update_ui)
		GameManager.player_data.equipment_changed.connect(update_ui)
		
	if pause_button:
		pause_button.pressed.connect(_on_pause_pressed)
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_leave_dungeon)
		
	# Hide TileMapLayer to show our new background
	call_deferred("_setup_background")

func _setup_background() -> void:
	var map = get_tree().current_scene
	if map and map.name == "Map":
		var tm = map.get_node_or_null("TileMapLayer")
		if tm:
			tm.visible = false
			
		var bg_sprite = Sprite2D.new()
		bg_sprite.texture = load("res://assets/sprites/tilesets/forest_map.png")
		bg_sprite.z_index = -100
		
		# Tính toán scale để phủ vừa đủ khu vực trung tâm map (khoảng 360x640 trở lên)
		bg_sprite.scale = Vector2(1.5, 1.5) 
		
		map.add_child(bg_sprite)
			
	# Reorganize Player/Pet HP
	if player_hp_bar and player_hp_bar.get_parent():
		player_hp_bar.get_parent().set_anchors_preset(Control.PRESET_TOP_LEFT)
		player_hp_bar.get_parent().position = Vector2(20, 20)
		
	# Create Boss HP Bar
	var canvas = CanvasLayer.new()
	canvas.layer = 5
	boss_hp_bar = ProgressBar.new()
	boss_hp_bar.custom_minimum_size = Vector2(600, 30)
	boss_hp_bar.set_anchors_preset(Control.PRESET_CENTER_TOP)
	boss_hp_bar.position.y = 20
	boss_hp_bar.visible = false
	
	var sb_bg = StyleBoxFlat.new()
	sb_bg.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	sb_bg.border_width_left = 2
	sb_bg.border_width_right = 2
	sb_bg.border_width_top = 2
	sb_bg.border_width_bottom = 2
	sb_bg.border_color = Color(0.4, 0.0, 0.0)
	boss_hp_bar.add_theme_stylebox_override("background", sb_bg)
	
	var sb_fill = StyleBoxFlat.new()
	sb_fill.bg_color = Color(0.8, 0.1, 0.1)
	boss_hp_bar.add_theme_stylebox_override("fill", sb_fill)
	
	canvas.add_child(boss_hp_bar)
	add_child(canvas)
	
	update_ui()

func show_boss_hp(max_hp: int) -> void:
	if boss_hp_bar:
		boss_hp_bar.max_value = max_hp
		boss_hp_bar.value = max_hp
		boss_hp_bar.visible = true

func update_boss_hp(current_hp: int) -> void:
	if boss_hp_bar:
		boss_hp_bar.value = current_hp
		if current_hp <= 0:
			boss_hp_bar.visible = false

func _process(delta: float) -> void:
	pass

func update_ui() -> void:
	var pd = GameManager.player_data
	if not pd: return
	
	if player_level_label:
		player_level_label.text = "Lv." + str(pd.level)
	if player_hp_bar:
		player_hp_bar.max_value = pd.get_total_hp()
		player_hp_bar.value = pd.get_total_hp()
	if player_exp_bar:
		player_exp_bar.max_value = pd.exp_to_next_level
		player_exp_bar.value = pd.exp
		
	var active = GameManager.get_active_pet()
	if pet_level_label:
		pet_level_label.text = "Lv." + str(active.level if active else 1)
	if pet_hp_bar:
		pet_hp_bar.max_value = GameManager.get_pet_total_hp()
		pet_hp_bar.value = GameManager.get_pet_total_hp()
	if pet_exp_bar:
		pet_exp_bar.max_value = active.exp_to_next if active else 100
		pet_exp_bar.value = active.exp if active else 0
		
	if inventory_label:
		inventory_label.text = "Items: " + str(pd.inventory.size())
		
	if inventory_label:
		inventory_label.text = "Items: " + str(pd.inventory.size())

func _on_pet_evolved() -> void:
	update_ui()

func _on_pause_pressed() -> void:
	if pause_menu:
		pause_menu.visible = true
		get_tree().paused = true
		_update_stats_menu()

func _on_resume_pressed() -> void:
	if pause_menu:
		pause_menu.visible = false
		get_tree().paused = false

func _update_stats_menu() -> void:
	var pd = GameManager.player_data
	if not pd: return
	
	var total_hp = pd.get_total_hp()
	var total_atk = pd.get_total_atk()
	var total_def = pd.get_total_def()
	
	if stats_hp: stats_hp.text = "HP: " + str(total_hp) + "/" + str(total_hp)
	if stats_atk: stats_atk.text = "ATK: " + str(total_atk)
	if stats_def: stats_def.text = "DEF: " + str(total_def)

func _on_leave_dungeon() -> void:
	get_tree().paused = false
	GameManager.save_game()
	get_tree().change_scene_to_file("res://scenes/ui/Lobby.tscn")
