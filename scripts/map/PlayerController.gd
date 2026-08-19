extends CharacterBody2D

@export var speed: float = 150.0
@export var virtual_joystick: CustomJoystick

@onready var sprite: Sprite2D = $Sprite2D

var realtime_max_hp: int = 1
var realtime_current_hp: int = 1
var is_invulnerable: bool = false
var is_dead: bool = false
var hp_bar: ProgressBar

func _ready() -> void:
	if GameManager.is_realtime_combat:
		call_deferred("setup_realtime_combat")

func setup_realtime_combat() -> void:
	if not GameManager.player_data: return
	realtime_max_hp = int(GameManager.player_data.get_total_hp() * GameManager.realtime_hp_multiplier)
	realtime_current_hp = realtime_max_hp
	
	hp_bar = ProgressBar.new()
	hp_bar.position = Vector2(-20, -30)
	hp_bar.size = Vector2(40, 5)
	hp_bar.show_percentage = false
	hp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_bar.max_value = realtime_max_hp
	hp_bar.value = realtime_current_hp
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color.GREEN
	hp_bar.add_theme_stylebox_override("fill", sb)
	add_child(hp_bar)

func take_damage(enemy_atk: int) -> void:
	if not GameManager.is_realtime_combat or is_invulnerable or is_dead:
		return
		
	var p_def = GameManager.player_data.get_total_def()
	var dmg = max(1, int((enemy_atk / GameManager.enemy_atk_divisor) - p_def))
	GameManager.realtime_damage_taken_last = dmg
	
	realtime_current_hp -= dmg
	if hp_bar:
		hp_bar.value = realtime_current_hp
		
	if realtime_current_hp <= 0:
		is_dead = true
		sprite.modulate = Color.DARK_GRAY
		print("GAME OVER: Bạn đã bị quái vật đánh gục! Đang chờ hồi sinh...")
		
		# Đợi 3 giây rồi hồi sinh
		await get_tree().create_timer(3.0).timeout
		realtime_current_hp = realtime_max_hp
		if hp_bar:
			hp_bar.value = realtime_current_hp
		sprite.modulate = Color.WHITE
		is_dead = false
		
		# Cho thêm 2 giây bất tử sau khi hồi sinh để không bị chết nhồi
		is_invulnerable = true
		var tw = create_tween()
		tw.tween_property(sprite, "modulate", Color(1, 1, 1, 0.5), 0.1)
		tw.tween_property(sprite, "modulate", Color.WHITE, 0.1)
		tw.set_loops(20)
		await get_tree().create_timer(2.0).timeout
		is_invulnerable = false
		sprite.modulate = Color.WHITE
		
		return
		
	# I-Frame
	is_invulnerable = true
	GameManager.iframe_triggered_count += 1
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0, 0, 0.5), 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	tween.set_loops(int(GameManager.iframe_duration / 0.2))
	
	await get_tree().create_timer(GameManager.iframe_duration).timeout
	is_invulnerable = false
	sprite.modulate = Color.WHITE

func _physics_process(delta: float) -> void:
	if is_dead: return
	
	var direction := Vector2.ZERO
	
	if virtual_joystick and virtual_joystick.is_dragging:
		direction = (virtual_joystick.current_pos - virtual_joystick.center_pos).normalized()
	else:
		direction.x = Input.get_axis("ui_left", "ui_right")
		direction.y = Input.get_axis("ui_up", "ui_down")
		if direction.length() > 0:
			direction = direction.normalized()
	
	velocity = direction * speed
	move_and_slide()
