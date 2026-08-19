extends Area2D
class_name EnemyProjectile

@export var speed: float = 200.0
@export var damage: int = 10
@export var duration: float = 3.0

var direction: Vector2 = Vector2.RIGHT
var time_alive: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	var sprite = Sprite2D.new()
	# Dummy green/purple projectile
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.5, 0.0, 0.8, 1.0)) # Purple color
	var tex = ImageTexture.create_from_image(img)
	sprite.texture = tex
	add_child(sprite)
	
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 8.0
	col.shape = shape
	add_child(col)

func setup(dir: Vector2, dmg: int) -> void:
	direction = dir.normalized()
	damage = dmg
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	time_alive += delta
	if time_alive >= duration:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
