extends CharacterBody2D

@export var target: Node2D
@export var follow_distance: float = 40.0
@export var speed: float = 130.0

@onready var sprite: Sprite2D = $Sprite2D
var evo_shader = preload("res://resources/shaders/evolution_shader.gdshader")

func _ready() -> void:
	start_hover_animation()

	GameManager.pet_evolved.connect(_on_pet_evolved)
	
	# Setup Shader Material
	var mat = ShaderMaterial.new()
	mat.shader = evo_shader
	mat.set_shader_parameter("is_evolved", false)
	sprite.material = mat
	
	var active_pet = GameManager.get_active_pet()
	if active_pet and active_pet.pet_data:
		var p_data = active_pet.pet_data
		if p_data.monster_id == "thu_khoi_dau" or p_data.monster_id == "thu_tien_hoa":
			pass
		else:
			if p_data.sprite_frames != null and p_data.sprite_frames.has_animation("default"):
				sprite.texture = p_data.sprite_frames.get_frame_texture("default", 0)
				
	if GameManager.is_realtime_combat:
		setup_auto_attack()

var aggro_area: Area2D
var attack_timer: Timer
var projectile_scene = preload("res://scenes/combat/Projectile.tscn")

func setup_auto_attack() -> void:
	aggro_area = Area2D.new()
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 200.0
	col.shape = shape
	aggro_area.add_child(col)
	add_child(aggro_area)
	
	attack_timer = Timer.new()
	attack_timer.wait_time = 1.0
	attack_timer.autostart = true
	attack_timer.timeout.connect(_shoot_projectile)
	add_child(attack_timer)

func _shoot_projectile() -> void:
	var closest_enemy: Node2D = null
	var min_dist = 9999.0
	
	for area in aggro_area.get_overlapping_areas():
		if "monster_data" in area and not area.get("is_dead"):
			var d = global_position.distance_to(area.global_position)
			if d < min_dist:
				min_dist = d
				closest_enemy = area
				
	if closest_enemy and projectile_scene:
		play_attack_anim(closest_enemy.global_position)
		var proj = projectile_scene.instantiate()
		proj.global_position = global_position
		proj.direction = (closest_enemy.global_position - global_position).normalized()
		proj.damage = GameManager.get_pet_total_atk()
		var active_pet = GameManager.get_active_pet()
		var p_data = active_pet.pet_data if active_pet else null
		if p_data:
			proj.element = p_data.element
			proj.on_hit_effects = p_data.on_hit_effects
		get_tree().current_scene.add_child(proj)

func play_attack_anim(target_pos: Vector2) -> void:
	if not sprite: return
	var tw = create_tween()
	var orig_pos = sprite.position
	var dir = (target_pos - global_position).normalized()
	tw.tween_property(sprite, "position", orig_pos + dir * 15.0, 0.1).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(sprite, "position", orig_pos, 0.1).set_trans(Tween.TRANS_QUAD)

func play_hit_anim() -> void:
	if not sprite: return
	var tw = create_tween()
	sprite.modulate = Color(1.0, 0.4, 0.4)
	var orig_pos = sprite.position
	var shake = Vector2(randf_range(-5, 5), randf_range(-5, 5))
	tw.tween_property(sprite, "position", orig_pos + shake, 0.05)
	tw.tween_property(sprite, "position", orig_pos, 0.05)
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func _physics_process(delta: float) -> void:
	if not target: return
	
	var dist = global_position.distance_to(target.global_position)
	if dist > follow_distance:
		var dir = (target.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()

func _on_pet_evolved() -> void:
	# Bật shader đổi màu (Palette Swap/Tint)
	sprite.material.set_shader_parameter("is_evolved", true)
	
	# Hiệu ứng Tween: Rung / Phóng to (Đột phá uy lực)
	var tween = create_tween()
	# Phóng to rực rỡ
	tween.tween_property(sprite, "scale", Vector2(1.8, 1.8), 0.2).set_trans(Tween.TRANS_ELASTIC)
	# Trở về trạng thái to hơn bình thường 1 chút (thú to lên)
	tween.tween_property(sprite, "scale", Vector2(1.3, 1.3), 0.4).set_ease(Tween.EASE_OUT)


func start_hover_animation() -> void:
	if sprite:
		var orig_y = sprite.position.y
		var tween = create_tween().set_loops()
		tween.tween_property(sprite, "position:y", orig_y - 15.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(sprite, "position:y", orig_y, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
