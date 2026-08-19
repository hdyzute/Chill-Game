extends Label
class_name DamageText

func _init() -> void:
    add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
    add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
    add_theme_constant_override("outline_size", 4)
    add_theme_constant_override("shadow_offset_y", 2)
    add_theme_font_size_override("font_size", 24)
    horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func animate_damage(amount: int, is_crit: bool = false) -> void:
    text = str(amount)
    if is_crit:
        modulate = Color.GOLD
        scale = Vector2(1.5, 1.5)
        text = text + "!"
    else:
        modulate = Color.WHITE
        
    var tween = create_tween().set_parallel(true)
    
    var random_offset = Vector2(randf_range(-20, 20), -50)
    tween.tween_property(self, "position", position + random_offset, 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
    
    tween.tween_property(self, "scale", scale * 1.2, 0.2).set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "scale", scale * 0.8, 0.4).set_delay(0.2).set_ease(Tween.EASE_IN)
    
    tween.tween_property(self, "modulate:a", 0.0, 0.3).set_delay(0.3)
    
    tween.chain().tween_callback(queue_free)
