extends Area2D

@export var exp_amount: int = 50
var magnet_range: float = 100.0
var speed: float = 300.0
var player: Node2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	# Tạo hình kim cương xanh lấp lánh (nếu không có sprite sẵn)
	var poly = Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(0, -6), Vector2(4, 0), Vector2(0, 6), Vector2(-4, 0)])
	poly.color = Color.CYAN
	add_child(poly)
	
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 15.0
	col.shape = shape
	add_child(col)

func _physics_process(delta: float) -> void:
	if not player:
		player = get_tree().current_scene.get_node_or_null("Player")
		return
		
	if player and not player.get("is_dead") and global_position.distance_to(player.global_position) < magnet_range:
		var dir = (player.global_position - global_position).normalized()
		global_position += dir * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameManager.add_exp(exp_amount)
		queue_free()
