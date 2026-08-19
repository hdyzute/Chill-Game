extends CanvasLayer
class_name PetDetailView

signal back_requested
signal deploy_requested(index: int)
signal evolve_requested(index: int)

var pet_index: int = -1
var pet_instance: MonsterInstanceData = null
var is_active: bool = false

var evolve_btn: Button
var deploy_btn: Button

func _ready() -> void:
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.95)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)
	
	_build_ui()

func setup(index: int, pet: MonsterInstanceData, active: bool) -> void:
	pet_index = index
	pet_instance = pet
	is_active = active

func _build_ui() -> void:
	var pet = pet_instance
	var data = pet.pet_data
	var tier_color = PetCardSlot.get_tier_color(pet.bloodline_tier)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	add_child(vbox)
	
	# Center Visual
	var center_vbox = VBoxContainer.new()
	center_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center_vbox.add_theme_constant_override("separation", 10)
	vbox.add_child(center_vbox)
	
	var name_lbl = Label.new()
	name_lbl.text = data.monster_name
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 48)
	name_lbl.add_theme_color_override("font_color", tier_color)
	center_vbox.add_child(name_lbl)
	
	var lv_tier_lbl = Label.new()
	lv_tier_lbl.text = "Cấp: %d | Huyết mạch: %s | Hệ: %s" % [pet.level, pet.bloodline_tier, data.element if data.element != "" else "Thường"]
	lv_tier_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lv_tier_lbl.add_theme_font_size_override("font_size", 24)
	lv_tier_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	center_vbox.add_child(lv_tier_lbl)
	
	# Sprite
	var tex_rect = TextureRect.new()
	if data.monster_id == "thu_khoi_dau" or data.monster_id == "thu_tien_hoa":
		tex_rect.texture = load("res://assets/sprites/ui/UI_pet-fire-dragon.png")
	else:
		if data.sprite_frames != null and data.sprite_frames.has_animation("default"):
			tex_rect.texture = data.sprite_frames.get_frame_texture("default", 0)
		elif data.sprite_frames != null and data.sprite_frames.has_animation("idle"):
			tex_rect.texture = data.sprite_frames.get_frame_texture("idle", 0)
		
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.custom_minimum_size = Vector2(300, 300)
	center_vbox.add_child(tex_rect)
	
	var sep = HSeparator.new()
	sep.add_theme_constant_override("separation", 30)
	vbox.add_child(sep)
	
	# Stats Area
	var stats_grid = GridContainer.new()
	stats_grid.columns = 2
	stats_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	stats_grid.add_theme_constant_override("h_separation", 60)
	stats_grid.add_theme_constant_override("v_separation", 20)
	vbox.add_child(stats_grid)
	
	stats_grid.add_child(_create_stat_lbl("HP", str(pet.get_total_hp())))
	stats_grid.add_child(_create_stat_lbl("ATK", str(pet.get_total_atk())))
	stats_grid.add_child(_create_stat_lbl("DEF", str(pet.get_total_def())))
	stats_grid.add_child(_create_stat_lbl("SPD", "100")) # SPD placeholder for now
	
	# Action Buttons
	var action_hbox = HBoxContainer.new()
	action_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	action_hbox.add_theme_constant_override("separation", 40)
	vbox.add_child(action_hbox)
	
	deploy_btn = Button.new()
	deploy_btn.custom_minimum_size = Vector2(200, 80)
	deploy_btn.add_theme_font_size_override("font_size", 28)
	_style_button(deploy_btn, Color(0.1, 0.5, 0.2, 0.9) if not is_active else Color(0.5, 0.5, 0.5, 0.9))
	if is_active:
		deploy_btn.text = "ĐANG XUẤT CHIẾN"
		deploy_btn.disabled = true
	else:
		deploy_btn.text = "RA TRẬN"
		deploy_btn.pressed.connect(_on_deploy)
	action_hbox.add_child(deploy_btn)
	
	evolve_btn = Button.new()
	evolve_btn.custom_minimum_size = Vector2(200, 80)
	evolve_btn.add_theme_font_size_override("font_size", 28)
	_style_button(evolve_btn, Color(0.8, 0.5, 0.1, 0.9))
	
	var can_evo = GameManager.can_evolve() and is_active # For now, evolve logic in GameManager relies on active_pet. We'll improve this later.
	# Actually, to evolve a non-active pet, we need to check if they have evo stones and level.
	# Let's write custom logic for this specific pet:
	var has_stones = false
	for item in GameManager.player_data.inventory:
		if item == "evo_stone":
			has_stones = true
			break
			
	if not data:
		evolve_btn.text = "Lỗi"
		evolve_btn.disabled = true
	elif data.evolves_into == "":
		evolve_btn.text = "ĐÃ TỐI ĐA"
		evolve_btn.disabled = true
	else:
		if pet.level >= data.evolution_player_level_required and has_stones:
			evolve_btn.text = "TIẾN HÓA"
			evolve_btn.pressed.connect(_on_evolve)
		else:
			evolve_btn.text = "Cần Lv.%d & 1 Đá" % data.evolution_player_level_required
			evolve_btn.disabled = true
			
	action_hbox.add_child(evolve_btn)
	
	# Add a spacer
	var empty_spacer = Control.new()
	empty_spacer.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(empty_spacer)
	
	# Close button
	var close_btn = Button.new()
	close_btn.text = "ĐÓNG LẠI"
	close_btn.custom_minimum_size = Vector2(250, 60)
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_btn.add_theme_font_size_override("font_size", 28)
	_style_button(close_btn, Color(0.2, 0.2, 0.2, 0.9))
	close_btn.pressed.connect(func(): back_requested.emit(); queue_free())
	vbox.add_child(close_btn)

func _create_stat_lbl(stat_name: String, value: String) -> Label:
	var l = Label.new()
	l.text = stat_name + ": " + value
	l.add_theme_font_size_override("font_size", 32)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func _style_button(btn: Button, color: Color) -> void:
	var sb = StyleBoxFlat.new()
	sb.bg_color = color
	sb.corner_radius_top_left = 15
	sb.corner_radius_top_right = 15
	sb.corner_radius_bottom_right = 15
	sb.corner_radius_bottom_left = 15
	
	var sb_pressed = sb.duplicate()
	sb_pressed.bg_color = color.darkened(0.3)
	
	var sb_disabled = sb.duplicate()
	sb_disabled.bg_color = Color(0.3, 0.3, 0.3, 0.9)
	
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("pressed", sb_pressed)
	btn.add_theme_stylebox_override("disabled", sb_disabled)
	btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS

func _on_deploy() -> void:
	deploy_requested.emit(pet_index)
	# Update button visually immediately
	deploy_btn.text = "ĐANG XUẤT CHIẾN"
	deploy_btn.disabled = true
	is_active = true

func _on_evolve() -> void:
	evolve_requested.emit(pet_index)
	# Will be handled by the parent / GameManager, then we should probably reload or close this view.
	# For simplicity, we just close the view and let them re-open to see changes, or we can just emit and close.
	back_requested.emit()
	queue_free()
