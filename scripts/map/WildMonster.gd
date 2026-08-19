extends Area2D

@export var monster_data: MonsterData
@export var wander_radius: float = 100.0
@export var wander_speed: float = 30.0

@onready var sprite: Sprite2D = $Sprite2D

var spawn_origin: Vector2
var wander_target: Vector2
var is_wandering: bool = false
var wander_timer: float = 0.0
var can_move: bool = true
var hop_tween: Tween

var current_hp: int = 1
var knockback_velocity: Vector2 = Vector2.ZERO
var exp_drop_scene = preload("res://scenes/map/EXPDrop.tscn")
var item_drop_scene = preload("res://scenes/map/EquipmentDrop.tscn")

var hp_bar: ProgressBar
var active_status_effects: Dictionary = {}

func apply_status_effect(effect: StatusEffectData) -> void:
	if effect == null:
		return
	if active_status_effects.has(effect.effect_id):
		active_status_effects[effect.effect_id].time_left = effect.duration
	else:
		active_status_effects[effect.effect_id] = {
			"data": effect,
			"time_left": effect.duration,
			"time_since_last_tick": 0.0
		}

func get_speed_multiplier() -> float:
	var mult = 1.0
	for eff_id in active_status_effects:
		var eff = active_status_effects[eff_id].data
		if eff.effect_type == "slow":
			mult *= (1.0 - eff.magnitude)
	return max(0.1, mult)

func _ready() -> void:
	add_to_group("wild_monsters")
	body_entered.connect(_on_body_entered)
	spawn_origin = global_position
	pick_new_wander_target()
	

	if monster_data:
		current_hp = monster_data.base_hp
		if monster_data.is_boss:
			scale = Vector2(2.0, 2.0)
			if sprite:
				sprite.modulate = Color(0.8, 0.1, 0.8, 1.0)
			var ui = get_tree().current_scene.get_node_or_null("MainUI")
			if ui and ui.has_method("show_boss_hp"):
				ui.show_boss_hp(current_hp)
	
	# Khởi tạo thanh máu
	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(30, 6)
	hp_bar.position = Vector2(-15, -25)
	hp_bar.show_percentage = false
	hp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var style_bg = StyleBoxFlat.new()
	style_bg.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	style_bg.corner_radius_top_left = 2
	style_bg.corner_radius_top_right = 2
	style_bg.corner_radius_bottom_left = 2
	style_bg.corner_radius_bottom_right = 2
	hp_bar.add_theme_stylebox_override("background", style_bg)
	
	var style_fg = StyleBoxFlat.new()
	style_fg.bg_color = Color(0.9, 0.2, 0.2, 1.0)
	style_fg.corner_radius_top_left = 2
	style_fg.corner_radius_top_right = 2
	style_fg.corner_radius_bottom_left = 2
	style_fg.corner_radius_bottom_right = 2
	hp_bar.add_theme_stylebox_override("fill", style_fg)
	
	if monster_data and monster_data.is_boss:
		hp_bar.custom_minimum_size = Vector2(60, 8)
		hp_bar.position = Vector2(-30, -35)
		
	hp_bar.max_value = current_hp
	hp_bar.value = current_hp
	hp_bar.visible = false # Ẩn cho đến khi bị đánh
	add_child(hp_bar)

func _physics_process(delta: float) -> void:
	# Xử lý hiệu ứng trạng thái
	var to_remove = []
	for eff_id in active_status_effects.keys():
		var state = active_status_effects[eff_id]
		state.time_left -= delta
		var eff = state.data
		
		if eff.effect_type == "dot":
			state.time_since_last_tick += delta
			if state.time_since_last_tick >= eff.tick_interval:
				state.time_since_last_tick -= eff.tick_interval
				take_damage(eff.magnitude, Vector2.ZERO)
				if sprite:
					sprite.modulate = eff.vfx_color
					var tw = create_tween()
					var orig_color = Color(0.8, 0.1, 0.8, 1.0) if (monster_data and monster_data.is_boss) else Color.WHITE
					tw.tween_property(sprite, "modulate", orig_color, 0.2)
					
		elif eff.effect_type == "slow":
			if randf() < 0.05 and sprite:
				sprite.modulate = eff.vfx_color
				var tw = create_tween()
				var orig_color = Color(0.8, 0.1, 0.8, 1.0) if (monster_data and monster_data.is_boss) else Color.WHITE
				tw.tween_property(sprite, "modulate", orig_color, 0.1)
				
		if state.time_left <= 0:
			to_remove.append(eff_id)
			
	for eff_id in to_remove:
		active_status_effects.erase(eff_id)

	if knockback_velocity.length() > 10:
		global_position += knockback_velocity * delta
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 10 * delta)
		return
		
	if not can_move: return
		
	if GameManager.is_realtime_combat:
		for body in get_overlapping_bodies():
			if body.name == "Player" and body.has_method("take_damage"):
				var atk = monster_data.base_atk if monster_data else 10
				body.take_damage(atk)
				play_attack_anim(body.global_position)
				
		var player = get_tree().current_scene.get_node_or_null("Player")
		if player and not player.get("is_dead"):
			var dir = (player.global_position - global_position).normalized()
			global_position += dir * wander_speed * 1.5 * get_speed_multiplier() * delta
			if sprite: sprite.flip_h = dir.x < 0
			_do_hop()
	else:
		if not is_wandering:
			wander_timer -= delta
			if wander_timer <= 0:
				pick_new_wander_target()
				is_wandering = true
		
		if is_wandering:
			var dir = (wander_target - global_position).normalized()
			global_position += dir * wander_speed * get_speed_multiplier() * delta
			if sprite: sprite.flip_h = dir.x < 0
			_do_hop()
			if global_position.distance_to(wander_target) < 2.0:
				is_wandering = false
				wander_timer = randf_range(2.0, 5.0)

func _do_hop() -> void:
	if not sprite: return
	if hop_tween and hop_tween.is_valid(): return
	
	hop_tween = create_tween()
	hop_tween.tween_property(sprite, "position:y", -10.0, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	hop_tween.tween_property(sprite, "position:y", 0.0, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func pick_new_wander_target() -> void:
	var random_offset = Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius)
	)
	wander_target = spawn_origin + random_offset

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if GameManager.is_realtime_combat:
			if body.has_method("take_damage"):
				var atk = monster_data.base_atk if monster_data else 10
				body.take_damage(atk)
			return
			
		if not monster_data: return
		set_deferred("monitoring", false)
		GameManager.start_combat(self, monster_data)

func take_damage(amount: int, kb_vector: Vector2) -> void:
	current_hp -= amount
	var kb_mult = GameManager.boss_knockback_multiplier if (monster_data and monster_data.is_boss) else 1.0
	knockback_velocity = kb_vector * kb_mult
	
	if hp_bar:
		hp_bar.visible = true
		hp_bar.value = current_hp
		
	if monster_data and monster_data.is_boss:
		var ui = get_tree().current_scene.get_node_or_null("MainUI")
		if ui and ui.has_method("update_boss_hp"):
			ui.update_boss_hp(current_hp)
	
	if sprite:
		play_hit_anim()
		
	var dmg_txt = DamageText.new()
	get_tree().current_scene.add_child(dmg_txt)
	dmg_txt.global_position = global_position + Vector2(0, -40)
	dmg_txt.animate_damage(amount, randf() < 0.2)
		
	if current_hp <= 0:
		die()

func play_hit_anim() -> void:
	if not sprite: return
	var tw = create_tween()
	var orig_color = Color(0.8, 0.1, 0.8, 1.0) if (monster_data and monster_data.is_boss) else Color.WHITE
	
	sprite.modulate = Color(1.0, 0.4, 0.4)
	var orig_pos = sprite.position
	var shake = Vector2(randf_range(-5, 5), randf_range(-5, 5))
	tw.tween_property(sprite, "position", orig_pos + shake, 0.05)
	tw.tween_property(sprite, "position", orig_pos, 0.05)
	tw.tween_property(sprite, "modulate", orig_color, 0.1)

func play_attack_anim(target_pos: Vector2) -> void:
	if not sprite: return
	var tw = create_tween()
	var orig_pos = sprite.position
	var dir = (target_pos - global_position).normalized()
	tw.tween_property(sprite, "position", orig_pos + dir * 15.0, 0.1).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(sprite, "position", orig_pos, 0.1).set_trans(Tween.TRANS_QUAD)

func die() -> void:
	if not GameManager.is_realtime_combat: return
	if exp_drop_scene:
		var exp_drop = exp_drop_scene.instantiate()
		exp_drop.global_position = global_position
		exp_drop.set("exp_amount", monster_data.exp_reward if monster_data else 50)
		get_tree().current_scene.call_deferred("add_child", exp_drop)
	
	var drop_rate = monster_data.drop_rate_evo_stone if monster_data else 0.5
	if randf() < drop_rate and item_drop_scene:
		var item_drop = item_drop_scene.instantiate()
		item_drop.global_position = global_position + Vector2(randf_range(-15,15), randf_range(-15,15))
		get_tree().current_scene.call_deferred("add_child", item_drop)
		
	GameManager.battles_fought += 1
	
	var gold_dropped = 100 if (monster_data and monster_data.is_boss) else randi_range(10, 30)
	if GameManager.player_data:
		GameManager.player_data.gold += gold_dropped
		GameManager.player_data.stats_changed.emit()
		
	queue_free()
