extends Area2D

var damage: int = 0
var max_radius: float = 150.0

func _ready() -> void:
	# 1. Ring shockwave
	var poly = Polygon2D.new()
	var points = PackedVector2Array()
	for i in range(32):
		var angle = i * PI * 2 / 32
		points.append(Vector2(cos(angle), sin(angle)) * max_radius)
	poly.polygon = points
	poly.color = Color(1.0, 0.5, 0.0, 0.6)
	add_child(poly)
	
	# 2. Flash trắng ngắn tại tâm
	var flash = Polygon2D.new()
	var flash_points = PackedVector2Array()
	for i in range(16):
		var angle = i * PI * 2 / 16
		flash_points.append(Vector2(cos(angle), sin(angle)) * (max_radius * 0.3))
	flash.polygon = flash_points
	flash.color = Color.WHITE
	add_child(flash)
	
	# 3. Particle burst
	var parts = CPUParticles2D.new()
	parts.emitting = true
	parts.amount = 30
	parts.one_shot = true
	parts.explosiveness = 1.0
	parts.spread = 180.0
	parts.gravity = Vector2.ZERO
	parts.initial_velocity_min = 200.0
	parts.initial_velocity_max = 400.0
	parts.scale_amount_min = 3.0
	parts.scale_amount_max = 8.0
	parts.color = Color(1.0, 0.8, 0.2)
	add_child(parts)
	
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = max_radius
	col.shape = shape
	add_child(col)
	
	scale = Vector2(0.1, 0.1)
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(flash, "modulate", Color(1, 1, 1, 0), 0.1)
	tw.tween_property(poly, "modulate", Color(1, 1, 1, 0), 0.2)
	tw.tween_callback(queue_free).set_delay(1.0)
	
	call_deferred("_apply_damage")

func _apply_damage() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	GameManager.kheuoc_damage_last = damage
	var hit_anything = false
	
	for area in get_overlapping_areas():
		if area.has_method("take_damage") and "monster_data" in area:
			var dir = (area.global_position - global_position).normalized()
			area.take_damage(damage, dir * 800.0)
			hit_anything = true
			
	if hit_anything:
		# 4. Hit-stop cực ngắn (~0.05s freeze frame)
		Engine.time_scale = 0.05
		await get_tree().create_timer(0.05, true, false, true).timeout # Bỏ qua time_scale
		Engine.time_scale = 1.0
		
		# 5. Screen shake nhẹ
		var cam = get_tree().current_scene.get_node_or_null("Player/Camera2D")
		if cam:
			var shake_tw = create_tween()
			for i in range(4):
				shake_tw.tween_property(cam, "offset", Vector2(randf_range(-15, 15), randf_range(-15, 15)), 0.03)
			shake_tw.tween_property(cam, "offset", Vector2.ZERO, 0.03)
