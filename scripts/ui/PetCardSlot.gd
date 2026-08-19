extends Button
class_name PetCardSlot

signal pet_selected(index: int)

var pet_index: int = -1
var pet_instance: MonsterInstanceData = null
var is_active_pet: bool = false

func _ready() -> void:
	custom_minimum_size = Vector2(75, 75)
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if not pet_instance or not pet_instance.pet_data:
		return
	pet_selected.emit(pet_index)

func setup(index: int, pet: MonsterInstanceData, active: bool) -> void:
	pet_index = index
	pet_instance = pet
	is_active_pet = active
	
	var data = pet.pet_data
	var tier_color = get_tier_color(pet.bloodline_tier)
	
	var sb = StyleBoxEmpty.new()
	add_theme_stylebox_override("normal", sb)
	add_theme_stylebox_override("hover", sb)
	add_theme_stylebox_override("focus", sb)
	add_theme_stylebox_override("pressed", sb)
	
	var bg = NinePatchRect.new()
	bg.texture = load("res://assets/sprites/ui/Card-slot.png")
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.modulate = tier_color # Optional: Tint the frame based on tier
	add_child(bg)
	
	var margin = MarginContainer.new()
	margin.set_anchors_preset(PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.clip_contents = true
	add_child(margin)
	
	if not data:
		var empty_lbl = Label.new()
		empty_lbl.text = "?"
		empty_lbl.set_anchors_preset(PRESET_FULL_RECT)
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		margin.add_child(empty_lbl)
		return
	
	var tex_rect = TextureRect.new()
	if data.monster_id == "thu_khoi_dau" or data.monster_id == "thu_tien_hoa":
		var raw_tex = load("res://assets/sprites/ui/UI_pet-fire-dragon.png")
		var atlas = AtlasTexture.new()
		atlas.atlas = raw_tex
		var w = raw_tex.get_width()
		atlas.region = Rect2(0, w * 0.05, w, w)
		tex_rect.texture = atlas
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	else:
		if data.sprite_frames != null and data.sprite_frames.has_animation("default"):
			tex_rect.texture = data.sprite_frames.get_frame_texture("default", 0)
		elif data.sprite_frames != null and data.sprite_frames.has_animation("idle"):
			tex_rect.texture = data.sprite_frames.get_frame_texture("idle", 0)
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
	tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(tex_rect)
	
	# Level badge in the bottom-right corner
	var lv_bg = ColorRect.new()
	lv_bg.color = Color(0, 0, 0, 0.7)
	lv_bg.custom_minimum_size = Vector2(30, 18)
	lv_bg.set_anchors_preset(PRESET_BOTTOM_RIGHT)
	lv_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(lv_bg)
	
	var lv_lbl = Label.new()
	lv_lbl.text = str(pet.level)
	lv_lbl.set_anchors_preset(PRESET_FULL_RECT)
	lv_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lv_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lv_lbl.add_theme_font_size_override("font_size", 12)
	lv_lbl.add_theme_color_override("font_color", Color.WHITE)
	lv_bg.add_child(lv_lbl)
	
	if active:
		var active_rect = ColorRect.new()
		active_rect.color = Color(0.8, 0.2, 0.2, 0.9)
		active_rect.set_anchors_preset(PRESET_BOTTOM_WIDE)
		active_rect.custom_minimum_size = Vector2(0, 16)
		active_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(active_rect)
		
		var active_lbl = Label.new()
		active_lbl.text = "XUẤT CHIẾN"
		active_lbl.set_anchors_preset(PRESET_FULL_RECT)
		active_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		active_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		active_lbl.add_theme_font_size_override("font_size", 10)
		active_lbl.add_theme_color_override("font_color", Color.WHITE)
		active_rect.add_child(active_lbl)

static func get_tier_color(tier: String) -> Color:
	match tier:
		"Thường": return Color(0.8, 0.8, 0.8) # White/Gray
		"Tốt": return Color(0.2, 0.8, 0.2) # Green
		"Xuất Sắc": return Color(0.8, 0.2, 1.0) # Purple
		"Hoàn Hảo": return Color(1.0, 0.8, 0.0) # Gold
	return Color.WHITE
