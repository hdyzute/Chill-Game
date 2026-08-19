extends Control

var tab_container: TabContainer
var bg_rect: TextureRect

# Top Bar Elements
var top_level_lbl: Label
var top_exp_bar: ProgressBar
var top_stones_lbl: Label
var top_gold_lbl: Label

# Tab 1: Home
var home_container: Control

# Tab 2: Pet
var pet_container: Control
var pet_grid: GridContainer

# Tab 3: Dungeon
var dungeon_container: Control
var enter_dungeon_btn: Button

func _ready() -> void:
	_build_ui()
	_update_ui()
	
	if GameManager:
		if not GameManager.pet_evolved.is_connected(_update_ui):
			GameManager.pet_evolved.connect(_update_ui)
		if GameManager.player_data and not GameManager.player_data.stats_changed.is_connected(_update_ui):
			GameManager.player_data.stats_changed.connect(_update_ui)
			
	if GameManager.player_data and GameManager.player_data.talent == null:
		var ts = load("res://scenes/ui/TalentSelection.tscn").instantiate()
		add_child(ts)

func _build_ui() -> void:
	# Background
	bg_rect = TextureRect.new()
	bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_rect.set_anchors_preset(PRESET_FULL_RECT)
	bg_rect.texture = load("res://assets/sprites/ui/bg_dungeon.jpg")
	bg_rect.modulate = Color(0.3, 0.3, 0.3)
	add_child(bg_rect)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_preset(PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 0)
	add_child(main_vbox)
	
	# ================= TOP BAR =================
	var top_bar = PanelContainer.new()
	var top_sb = StyleBoxFlat.new()
	top_sb.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	top_sb.border_width_bottom = 4
	top_sb.border_color = Color(0.4, 0.3, 0.1)
	top_bar.add_theme_stylebox_override("panel", top_sb)
	top_bar.custom_minimum_size = Vector2(0, 100)
	main_vbox.add_child(top_bar)
	
	var top_margin = MarginContainer.new()
	top_margin.add_theme_constant_override("margin_left", 20)
	top_margin.add_theme_constant_override("margin_right", 20)
	top_margin.add_theme_constant_override("margin_top", 10)
	top_margin.add_theme_constant_override("margin_bottom", 10)
	top_bar.add_child(top_margin)
	
	var top_hbox = HBoxContainer.new()
	top_margin.add_child(top_hbox)
	
	# Left Side (Player Avatar/Stats)
	var player_info = VBoxContainer.new()
	player_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_child(player_info)
	
	var name_lv_hbox = HBoxContainer.new()
	player_info.add_child(name_lv_hbox)
	
	var name_lbl = Label.new()
	name_lbl.text = "Ngự Thú Sư"
	name_lbl.add_theme_font_size_override("font_size", 20)
	name_lbl.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	name_lv_hbox.add_child(name_lbl)
	
	top_level_lbl = Label.new()
	top_level_lbl.add_theme_font_size_override("font_size", 20)
	top_level_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_level_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	name_lv_hbox.add_child(top_level_lbl)
	
	top_exp_bar = ProgressBar.new()
	top_exp_bar.custom_minimum_size = Vector2(0, 10)
	top_exp_bar.show_percentage = false
	var bg_exp = StyleBoxFlat.new()
	bg_exp.bg_color = Color(0.05, 0.05, 0.05)
	var fill_exp = StyleBoxFlat.new()
	fill_exp.bg_color = Color(0.95, 0.75, 0.15)
	top_exp_bar.add_theme_stylebox_override("background", bg_exp)
	top_exp_bar.add_theme_stylebox_override("fill", fill_exp)
	player_info.add_child(top_exp_bar)
	
	# Right Side (Currencies)
	var currency_info = VBoxContainer.new()
	currency_info.alignment = BoxContainer.ALIGNMENT_CENTER
	top_hbox.add_child(currency_info)
	
	top_stones_lbl = Label.new()
	top_stones_lbl.add_theme_font_size_override("font_size", 20)
	top_stones_lbl.add_theme_color_override("font_color", Color(0.8, 0.2, 0.8)) # Purple for stones
	currency_info.add_child(top_stones_lbl)
	
	top_gold_lbl = Label.new()
	top_gold_lbl.add_theme_font_size_override("font_size", 20)
	top_gold_lbl.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0)) # Gold color
	currency_info.add_child(top_gold_lbl)
	
	# ================= TAB CONTAINER =================
	tab_container = TabContainer.new()
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_container.tabs_visible = false # Hide default tabs, we use our own bottom bar
	
	var tab_sb = StyleBoxEmpty.new()
	tab_container.add_theme_stylebox_override("panel", tab_sb)
	main_vbox.add_child(tab_container)
	
	_build_home_tab()
	_build_pet_tab()
	_build_dungeon_tab()
	_build_stats_popup()
	
	# ================= BOTTOM NAV =================
	var nav_bar = PanelContainer.new()
	var nav_sb = StyleBoxFlat.new()
	nav_sb.bg_color = Color(0.1, 0.1, 0.1, 1.0)
	nav_sb.border_width_top = 4
	nav_sb.border_color = Color(0.4, 0.3, 0.1)
	nav_bar.add_theme_stylebox_override("panel", nav_sb)
	nav_bar.custom_minimum_size = Vector2(0, 120)
	main_vbox.add_child(nav_bar)
	
	var nav_hbox = HBoxContainer.new()
	nav_bar.add_child(nav_hbox)
	
	var btn_home = _create_nav_button("SẢNH", 0)
	var btn_pet = _create_nav_button("SỦNG THÚ", 1)
	var btn_dungeon = _create_nav_button("PHÓ BẢN", 2)
	
	nav_hbox.add_child(btn_home)
	nav_hbox.add_child(btn_pet)
	nav_hbox.add_child(btn_dungeon)
	
	# Default tab
	tab_container.current_tab = 1 # Pet Tab by default
	tab_container.tab_changed.connect(_on_tab_changed)

func _on_tab_changed(tab_idx: int) -> void:
	if tab_idx == 0:
		bg_rect.texture = load("res://assets/sprites/ui/bg_home.jpg")
		bg_rect.modulate = Color.WHITE
	elif tab_idx == 1:
		bg_rect.texture = load("res://assets/sprites/ui/bg_dungeon.jpg")
		bg_rect.modulate = Color(0.3, 0.3, 0.3)
	elif tab_idx == 2:
		bg_rect.texture = load("res://assets/sprites/ui/bg_dungeon.jpg")
		bg_rect.modulate = Color.WHITE

func _create_nav_button(text: String, tab_idx: int) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.add_theme_font_size_override("font_size", 32)
	
	var sb_normal = StyleBoxFlat.new()
	sb_normal.bg_color = Color(0.15, 0.15, 0.15, 0.9)
	var sb_pressed = StyleBoxFlat.new()
	sb_pressed.bg_color = Color(0.3, 0.3, 0.3, 0.9)
	
	btn.add_theme_stylebox_override("normal", sb_normal)
	btn.add_theme_stylebox_override("hover", sb_normal)
	btn.add_theme_stylebox_override("pressed", sb_pressed)
	btn.add_theme_stylebox_override("focus", sb_normal)
	
	btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	btn.pressed.connect(func(): tab_container.current_tab = tab_idx)
	return btn

func _build_home_tab() -> void:
	home_container = MarginContainer.new()
	tab_container.add_child(home_container)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	home_container.add_child(vbox)
	
	var lbl = Label.new()
	lbl.text = "[ KHU VỰC SẢNH ]\n\nNơi đây Ngự Thú Sư nghỉ ngơi.\n(Tính năng Trồng Trọt, Cửa Hàng sẽ cập nhật sau)"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 20)
	lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.custom_minimum_size = Vector2(300, 0)
	vbox.add_child(lbl)
	
	var btn_stats = Button.new()
	btn_stats.text = "XEM CHỈ SỐ"
	btn_stats.custom_minimum_size = Vector2(200, 60)
	btn_stats.add_theme_font_size_override("font_size", 24)
	var btn_sb = StyleBoxFlat.new()
	btn_sb.bg_color = Color(0.1, 0.3, 0.5, 0.9)
	btn_sb.corner_radius_top_left = 10
	btn_sb.corner_radius_top_right = 10
	btn_sb.corner_radius_bottom_right = 10
	btn_sb.corner_radius_bottom_left = 10
	
	var btn_sb_pressed = btn_sb.duplicate()
	btn_sb_pressed.bg_color = Color(0.05, 0.2, 0.4, 0.9)
	
	btn_stats.add_theme_stylebox_override("normal", btn_sb)
	btn_stats.add_theme_stylebox_override("hover", btn_sb)
	btn_stats.add_theme_stylebox_override("focus", btn_sb)
	btn_stats.add_theme_stylebox_override("pressed", btn_sb_pressed)
	btn_stats.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	btn_stats.pressed.connect(_on_view_stats)
	vbox.add_child(btn_stats)
	
	var btn_shop = Button.new()
	btn_shop.text = "CỬA HÀNG"
	btn_shop.custom_minimum_size = Vector2(200, 60)
	btn_shop.add_theme_font_size_override("font_size", 24)
	
	var shop_sb = StyleBoxFlat.new()
	shop_sb.bg_color = Color(0.8, 0.4, 0.1, 0.9)
	shop_sb.corner_radius_top_left = 10
	shop_sb.corner_radius_top_right = 10
	shop_sb.corner_radius_bottom_right = 10
	shop_sb.corner_radius_bottom_left = 10
	
	var shop_sb_pressed = shop_sb.duplicate()
	shop_sb_pressed.bg_color = Color(0.6, 0.3, 0.0, 0.9)
	
	btn_shop.add_theme_stylebox_override("normal", shop_sb)
	btn_shop.add_theme_stylebox_override("hover", shop_sb)
	btn_shop.add_theme_stylebox_override("focus", shop_sb)
	btn_shop.add_theme_stylebox_override("pressed", shop_sb_pressed)
	btn_shop.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	btn_shop.pressed.connect(_on_open_shop)
	vbox.add_child(btn_shop)
	
func _on_open_shop() -> void:
	if has_node("ShopUI"):
		return
		
	var shop_script = load("res://scripts/ui/Shop.gd")
	if shop_script:
		var shop_ui = shop_script.new()
		shop_ui.name = "ShopUI"
		add_child(shop_ui)

func _build_pet_tab() -> void:
	pet_container = MarginContainer.new()
	pet_container.add_theme_constant_override("margin_left", 30)
	pet_container.add_theme_constant_override("margin_right", 30)
	pet_container.add_theme_constant_override("margin_top", 30)
	pet_container.add_theme_constant_override("margin_bottom", 30)
	tab_container.add_child(pet_container)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	pet_container.add_child(vbox)
	
	var title = Label.new()
	title.text = "QUẢN LÝ SỦNG THÚ"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	vbox.add_child(title)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)
	
	var center = CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)
	
	pet_grid = GridContainer.new()
	pet_grid.columns = 4
	pet_grid.add_theme_constant_override("h_separation", 15)
	pet_grid.add_theme_constant_override("v_separation", 15)
	center.add_child(pet_grid)

func _refresh_pet_grid() -> void:
	if not pet_grid or not GameManager.player_data: return
	for child in pet_grid.get_children():
		child.queue_free()
		
	var roster = GameManager.player_data.pet_roster
	var active_index = GameManager.player_data.active_pet_index
	
	var pet_card_script = load("res://scripts/ui/PetCardSlot.gd")
	if not pet_card_script: return
	
	for i in range(roster.size()):
		var pet = roster[i]
		if pet:
			var slot = pet_card_script.new()
			slot.setup(i, pet, i == active_index)
			slot.pet_selected.connect(_on_pet_slot_selected)
			pet_grid.add_child(slot)

func _on_pet_slot_selected(index: int) -> void:
	var roster = GameManager.player_data.pet_roster
	if index < 0 or index >= roster.size(): return
	var pet = roster[index]
	
	var detail_script = load("res://scripts/ui/PetDetailView.gd")
	if detail_script:
		var detail = detail_script.new()
		detail.setup(index, pet, index == GameManager.player_data.active_pet_index)
		detail.deploy_requested.connect(_on_pet_deploy)
		detail.evolve_requested.connect(_on_pet_evolve_request)
		# Add to Lobby as a popup
		add_child(detail)

func _on_pet_deploy(index: int) -> void:
	GameManager.player_data.active_pet_index = index
	GameManager.save_game()
	_refresh_pet_grid()
	_update_ui()

func _on_pet_evolve_request(index: int) -> void:
	var roster = GameManager.player_data.pet_roster
	var pet = roster[index]
	var data = pet.pet_data
	
	# Custom evolve logic for specific index
	var has_stones = false
	var stone_index = -1
	for i in range(GameManager.player_data.inventory.size()):
		if GameManager.player_data.inventory[i] == "evo_stone":
			has_stones = true
			stone_index = i
			break
			
	if has_stones and pet.level >= data.evolution_player_level_required:
		GameManager.player_data.inventory.remove_at(stone_index)
		pet.pet_data = ResourceLoader.load("res://resources/monsters/" + data.evolves_into + ".tres")
		pet.level = 1
		pet.exp = 0
		GameManager.save_game()
		GameManager.pet_evolved.emit()
		_refresh_pet_grid()

func _build_dungeon_tab() -> void:
	dungeon_container = MarginContainer.new()
	tab_container.add_child(dungeon_container)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 50)
	dungeon_container.add_child(vbox)
	
	var title = Label.new()
	title.text = "KHU RỪNG SLIME"
	title.add_theme_font_size_override("font_size", 50)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var enter_btn = Button.new()
	enter_btn.text = "VÀO CHIẾN ĐẤU"
	enter_btn.custom_minimum_size = Vector2(400, 150)
	enter_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	enter_btn.add_theme_font_size_override("font_size", 48)
	
	var enter_sb = StyleBoxFlat.new()
	enter_sb.bg_color = Color(0.2, 0.6, 0.2, 0.9)
	enter_sb.corner_radius_top_left = 30
	enter_sb.corner_radius_top_right = 30
	enter_sb.corner_radius_bottom_right = 30
	enter_sb.corner_radius_bottom_left = 30
	
	var enter_sb_pressed = enter_sb.duplicate()
	enter_sb_pressed.bg_color = Color(0.1, 0.4, 0.1, 0.9)
	
	enter_btn.add_theme_stylebox_override("normal", enter_sb)
	enter_btn.add_theme_stylebox_override("hover", enter_sb)
	enter_btn.add_theme_stylebox_override("focus", enter_sb)
	enter_btn.add_theme_stylebox_override("pressed", enter_sb_pressed)
	
	enter_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	enter_btn.pressed.connect(_on_enter_dungeon)
	vbox.add_child(enter_btn)

func _update_ui() -> void:
	if not GameManager or not GameManager.player_data: return
	
	var pd = GameManager.player_data
	
	# Top bar
	top_level_lbl.text = "Lv." + str(pd.level)
	top_exp_bar.max_value = pd.exp_to_next_level
	top_exp_bar.value = pd.exp
	
	var evo_stones_count = 0
	for item in pd.inventory:
		if item == "evo_stone":
			evo_stones_count += 1
	top_stones_lbl.text = "Đá Tiến Hóa: " + str(evo_stones_count)
	top_gold_lbl.text = "Vàng: " + str(pd.gold)
	
	# Update grid when stats change or pet evolved
	_refresh_pet_grid()

func _on_enter_dungeon() -> void:
	if not GameManager.get_active_pet():
		print("Vui lòng mua 1 Sủng Thú tại Cửa Hàng trước khi vào Phó Bản!")
		return
	get_tree().change_scene_to_file("res://scenes/Map_1.tscn")

var stats_panel: Control
var stats_lbl: Label

func _build_stats_popup() -> void:
	stats_panel = Control.new()
	stats_panel.set_anchors_preset(PRESET_FULL_RECT)
	stats_panel.hide()
	add_child(stats_panel)
	
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.8)
	dim.set_anchors_preset(PRESET_FULL_RECT)
	stats_panel.add_child(dim)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	stats_panel.add_child(center)
	
	var p_panel = PanelContainer.new()
	var p_sb = StyleBoxFlat.new()
	p_sb.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	p_sb.border_width_bottom = 6
	p_sb.border_color = Color(0.4, 0.3, 0.1)
	p_sb.corner_radius_top_left = 15
	p_sb.corner_radius_top_right = 15
	p_sb.corner_radius_bottom_right = 15
	p_sb.corner_radius_bottom_left = 15
	p_panel.add_theme_stylebox_override("panel", p_sb)
	center.add_child(p_panel)
	
	var p_margin = MarginContainer.new()
	p_margin.add_theme_constant_override("margin_left", 60)
	p_margin.add_theme_constant_override("margin_right", 60)
	p_margin.add_theme_constant_override("margin_top", 60)
	p_margin.add_theme_constant_override("margin_bottom", 60)
	p_panel.add_child(p_margin)
	
	var p_vbox = VBoxContainer.new()
	p_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	p_margin.add_child(p_vbox)
	
	stats_lbl = Label.new()
	stats_lbl.add_theme_font_size_override("font_size", 20)
	stats_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p_vbox.add_child(stats_lbl)
	
	var close_btn = Button.new()
	close_btn.text = "ĐÓNG"
	close_btn.custom_minimum_size = Vector2(200, 60)
	close_btn.add_theme_font_size_override("font_size", 24)
	
	var cb_sb = StyleBoxFlat.new()
	cb_sb.bg_color = Color(0.1, 0.3, 0.5, 0.9)
	cb_sb.corner_radius_top_left = 10
	cb_sb.corner_radius_top_right = 10
	cb_sb.corner_radius_bottom_right = 10
	cb_sb.corner_radius_bottom_left = 10
	
	var cb_sb_pressed = cb_sb.duplicate()
	cb_sb_pressed.bg_color = Color(0.05, 0.2, 0.4, 0.9)
	
	close_btn.add_theme_stylebox_override("normal", cb_sb)
	close_btn.add_theme_stylebox_override("hover", cb_sb)
	close_btn.add_theme_stylebox_override("focus", cb_sb)
	close_btn.add_theme_stylebox_override("pressed", cb_sb_pressed)
	close_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	
	close_btn.pressed.connect(func(): stats_panel.hide())
	p_vbox.add_child(close_btn)

func _on_view_stats() -> void:
	if not GameManager or not GameManager.player_data: return
	var p = GameManager.player_data
	var t = "--- NGỰ THÚ SƯ ---\n"
	t += "Cấp: %d\n" % p.level
	t += "HP: %d\n" % p.get_total_hp()
	t += "ATK: %d\n" % p.get_total_atk()
	t += "DEF: %d\n" % p.get_total_def()
	t += "Thiên Phú: %s\n" % (p.talent.talent_name if p.talent else "Chưa có")
	t += "Vũ khí: %s\n" % (p.equipped_weapon.equip_name if p.equipped_weapon else "Trống")
	t += "Giáp: %s\n" % (p.equipped_armor.equip_name if p.equipped_armor else "Trống")
	
	stats_lbl.text = t
	stats_panel.show()
