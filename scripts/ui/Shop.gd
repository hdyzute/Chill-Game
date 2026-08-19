extends Control
class_name ShopUI

signal closed

var gold_lbl: Label

func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_check_refresh()
	_build_ui()

func _check_refresh() -> void:
	var pd = GameManager.player_data
	var today = Time.get_date_dict_from_system()
	var last = pd.last_shop_refresh_date
	
	var needs_refresh = false
	if last.is_empty() or last.year != today.year or last.month != today.month or last.day != today.day:
		needs_refresh = true
		
	if needs_refresh:
		pd.last_shop_refresh_date = today
		pd.shop_daily_pets.clear()
		
		var all_monsters = MonsterDatabase.monsters.values()
		if all_monsters.size() > 0:
			for i in range(3):
				var r_template = all_monsters[randi() % all_monsters.size()]
				var new_pet = MonsterInstanceData.generate_new(r_template)
				pd.shop_daily_pets.append(new_pet)
		
		GameManager.save_game()

func get_pet_price(tier: String) -> int:
	if tier == "Hoàn Hảo": return 1000
	elif tier == "Xuất Sắc": return 400
	elif tier == "Tốt": return 150
	return 50

func _build_ui() -> void:
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.9)
	dim.set_anchors_preset(PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 40)
	add_child(vbox)
	
	var title = Label.new()
	title.text = "CỬA HÀNG SỦNG THÚ"
	title.add_theme_font_size_override("font_size", 48)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
	vbox.add_child(title)
	
	gold_lbl = Label.new()
	gold_lbl.text = "Vàng hiện có: " + str(GameManager.player_data.gold)
	gold_lbl.add_theme_font_size_override("font_size", 32)
	gold_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(gold_lbl)
	GameManager.player_data.stats_changed.connect(_on_stats_changed)
	
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 20)
	vbox.add_child(hbox)
	
	var pd = GameManager.player_data
	for i in range(pd.shop_daily_pets.size()):
		var pet = pd.shop_daily_pets[i]
		
		var p_panel = PanelContainer.new()
		var p_sb = StyleBoxFlat.new()
		p_sb.bg_color = Color(0.15, 0.15, 0.15, 0.9)
		p_sb.corner_radius_top_left = 15
		p_sb.corner_radius_top_right = 15
		p_sb.corner_radius_bottom_right = 15
		p_sb.corner_radius_bottom_left = 15
		p_panel.add_theme_stylebox_override("panel", p_sb)
		p_panel.custom_minimum_size = Vector2(220, 300)
		hbox.add_child(p_panel)
		
		var p_vbox = VBoxContainer.new()
		p_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		p_vbox.add_theme_constant_override("separation", 15)
		p_panel.add_child(p_vbox)
		
		if pet == null:
			var name_lbl = Label.new()
			name_lbl.text = "ĐÃ BÁN"
			name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			name_lbl.add_theme_font_size_override("font_size", 28)
			name_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
			p_vbox.add_child(name_lbl)
			continue
			
		var name_lbl = Label.new()
		name_lbl.text = pet.pet_data.monster_name
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 28)
		p_vbox.add_child(name_lbl)
		
		var tier_lbl = Label.new()
		tier_lbl.text = "Huyết Mạch:\n" + pet.bloodline_tier
		tier_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tier_lbl.add_theme_font_size_override("font_size", 20)
		
		# Huyết mạch color
		if pet.bloodline_tier == "Hoàn Hảo": tier_lbl.add_theme_color_override("font_color", Color(1.0, 0.4, 0.2))
		elif pet.bloodline_tier == "Xuất Sắc": tier_lbl.add_theme_color_override("font_color", Color(0.8, 0.2, 1.0))
		elif pet.bloodline_tier == "Tốt": tier_lbl.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
		else: tier_lbl.add_theme_color_override("font_color", Color.WHITE)
		
		p_vbox.add_child(tier_lbl)
		
		var price = get_pet_price(pet.bloodline_tier)
		
		var buy_btn = Button.new()
		buy_btn.text = str(price) + " Vàng"
		buy_btn.custom_minimum_size = Vector2(150, 50)
		buy_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		var b_sb = StyleBoxFlat.new()
		b_sb.bg_color = Color(0.8, 0.6, 0.1, 0.9)
		buy_btn.add_theme_stylebox_override("normal", b_sb)
		var b_sb_pressed = b_sb.duplicate()
		b_sb_pressed.bg_color = Color(0.5, 0.3, 0.0, 0.9)
		buy_btn.add_theme_stylebox_override("pressed", b_sb_pressed)
		
		buy_btn.pressed.connect(_on_buy_pressed.bind(i, price, buy_btn))
		p_vbox.add_child(buy_btn)
		
	var close_btn = Button.new()
	close_btn.text = "ĐÓNG CỬA HÀNG"
	close_btn.custom_minimum_size = Vector2(300, 60)
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_btn.add_theme_font_size_override("font_size", 28)
	close_btn.pressed.connect(func(): queue_free(); closed.emit())
	vbox.add_child(close_btn)

func _on_buy_pressed(index: int, price: int, btn: Button) -> void:
	var pd = GameManager.player_data
	if pd.gold >= price:
		pd.gold -= price
		var pet = pd.shop_daily_pets[index]
		if pet != null:
			pd.pet_roster.append(pet)
			pd.shop_daily_pets[index] = null # Mark as bought
			
			# If this is their first pet, make sure it's active immediately
			if pd.pet_roster.size() == 1:
				pd.active_pet_index = 0
				
			pd.stats_changed.emit()
			btn.text = "ĐÃ MUA"
			btn.disabled = true
			GameManager.save_game()
	else:
		btn.text = "KHÔNG ĐỦ VÀNG"
		await get_tree().create_timer(1.0).timeout
		if is_instance_valid(btn) and not btn.disabled:
			btn.text = str(price) + " Vàng"

func _on_stats_changed() -> void:
	if is_instance_valid(gold_lbl) and GameManager.player_data:
		gold_lbl.text = "Vàng hiện có: " + str(GameManager.player_data.gold)
