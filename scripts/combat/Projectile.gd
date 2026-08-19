extends Area2D

@export var speed: float = 400.0
@export var damage: int = 10
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.ZERO
var on_hit_effects: Array[StatusEffectData] = []
var element: String = "Normal"

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
	var sprite = Sprite2D.new()
	var blended = Color(1.0, 0.4, 0.0) # Default orange fireball
	if not on_hit_effects.is_empty():
		blended = Color(0, 0, 0, 0)
		for effect in on_hit_effects:
			if effect:
				blended += effect.vfx_color
		blended /= on_hit_effects.size()
		blended.a = 1.0
	
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(blended)
	sprite.texture = ImageTexture.create_from_image(img)
	add_child(sprite)
	
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 12.0
	col.shape = shape
	add_child(col)
	
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage") and "monster_data" in area:
		area.take_damage(damage, direction * 250.0)
		if area.has_method("apply_status_effect"):
			for eff in on_hit_effects:
				area.apply_status_effect(eff)
		queue_free()
