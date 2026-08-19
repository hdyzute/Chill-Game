extends CanvasLayer

@onready var panel: PanelContainer = $PanelContainer
@onready var lbl_time: Label = $PanelContainer/VBox/LblTime
@onready var lbl_battles: Label = $PanelContainer/VBox/LblBattles
@onready var lbl_stones: Label = $PanelContainer/VBox/LblStones
@onready var lbl_evo: Label = $PanelContainer/VBox/LblEvoTime
@onready var lbl_level: Label = $PanelContainer/VBox/LblLevel
@onready var toggle_btn: Button = $ToggleBtn
@onready var vbox: VBoxContainer = $PanelContainer/VBox

var lbl_rt_hp: Label
var lbl_rt_dmg: Label
var lbl_rt_iframe: Label
var lbl_rt_kheuoc: Label
var lbl_fps: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	toggle_btn.pressed.connect(_on_toggle)
	panel.visible = false # Ẩn mặc định để không làm phiền
	
	lbl_rt_hp = Label.new()
	lbl_rt_dmg = Label.new()
	lbl_rt_iframe = Label.new()
	lbl_rt_kheuoc = Label.new()
	lbl_fps = Label.new()
	vbox.add_child(lbl_rt_hp)
	vbox.add_child(lbl_rt_dmg)
	vbox.add_child(lbl_rt_iframe)
	vbox.add_child(lbl_rt_kheuoc)
	vbox.add_child(lbl_fps)
	var btn_test_leak = Button.new()
	btn_test_leak.text = "TEST RESOURCE LEAK"
	btn_test_leak.pressed.connect(_on_test_leak_pressed)
	vbox.add_child(btn_test_leak)
	
	lbl_test_result = Label.new()
	lbl_test_result.modulate = Color.YELLOW
	vbox.add_child(lbl_test_result)

var lbl_test_result: Label

func _on_test_leak_pressed() -> void:
	var wild_nodes = get_tree().get_nodes_in_group("wild_monsters")
	if wild_nodes.is_empty():
		var msg = "[TEST] Không có Wild Monster trên map."
		print(msg)
		lbl_test_result.text = msg
		_clear_test_result()
		return
	
	var wild = wild_nodes[0]
	var msg = ""
	if wild.monster_data:
		msg += "[TEST] Wild (%s) effects: %d\n" % [wild.monster_data.monster_id, wild.monster_data.on_hit_effects.size()]
	
	var active = GameManager.get_active_pet()
	var pet_data = active.pet_data if active else null
	if pet_data:
		msg += "[TEST] Player (%s) effects: %d" % [pet_data.monster_id, pet_data.on_hit_effects.size()]
		
	print(msg)
	lbl_test_result.text = msg
	_clear_test_result()

func _clear_test_result() -> void:
	await get_tree().create_timer(5.0).timeout
	if lbl_test_result:
		lbl_test_result.text = ""

func _process(_delta: float) -> void:
	if not panel.visible:
		return
	
	if GameManager:
		var mins = int(GameManager.play_time) / 60
		var secs = int(GameManager.play_time) % 60
		lbl_time.text = "Play Time: %02d:%02d" % [mins, secs]
		lbl_battles.text = "Battles Fought: %d" % GameManager.battles_fought
		lbl_stones.text = "Evo Stones: %d" % GameManager.evo_stones_dropped
		
		if GameManager.time_to_first_evo > 0:
			var emins = int(GameManager.time_to_first_evo) / 60
			var esecs = int(GameManager.time_to_first_evo) % 60
			lbl_evo.text = "First Evo at: %02d:%02d" % [emins, esecs]
		else:
			lbl_evo.text = "First Evo at: Not yet"
			
		var active = GameManager.get_active_pet()
		if active:
			lbl_level.text = "Player Lv: %d | Pet Lv: %d" % [GameManager.player_data.level, active.level]

		if GameManager.is_realtime_combat and get_tree().current_scene:
			var player = get_tree().current_scene.get_node_or_null("Player")
			if player:
				lbl_rt_hp.text = "Player HP: %d / %d" % [player.get("realtime_current_hp"), player.get("realtime_max_hp")]
			lbl_rt_dmg.text = "Last Dmg Taken: %d" % GameManager.realtime_damage_taken_last
			lbl_rt_iframe.text = "I-Frame Triggers: %d" % GameManager.iframe_triggered_count
			lbl_rt_kheuoc.text = "AoE Nuke Dmg: %d" % GameManager.kheuoc_damage_last
			lbl_fps.text = "FPS: %d" % Engine.get_frames_per_second()
		else:
			lbl_rt_hp.text = ""
			lbl_rt_dmg.text = ""
			lbl_rt_iframe.text = ""
			lbl_rt_kheuoc.text = ""
			lbl_fps.text = ""

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F1:
			_on_toggle()

func _on_toggle() -> void:
	panel.visible = not panel.visible
