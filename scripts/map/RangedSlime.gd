extends "res://scripts/map/WildMonster.gd"

var shoot_timer: float = 3.0
var shoot_interval: float = 4.0
var enemy_projectile_scene = preload("res://scenes/combat/EnemyProjectile.tscn")

func _ready() -> void:
	super._ready()
	# Replace default sprite with a purple one if no boss data
	if sprite and not (monster_data and monster_data.is_boss):
		sprite.modulate = Color(0.7, 0.2, 0.9)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not GameManager.is_realtime_combat:
		return
		
	var player = get_tree().current_scene.get_node_or_null("Player")
	if not player or player.get("is_dead"):
		can_move = true
		return
		
	var dist = global_position.distance_to(player.global_position)
	if dist < 250.0:
		can_move = false
		shoot_timer -= delta
		if shoot_timer <= 0.0:
			shoot_timer = shoot_interval
			_shoot_at_player(player)
	else:
		can_move = true

func _shoot_at_player(player: Node2D) -> void:
	if not enemy_projectile_scene: return
	var proj = enemy_projectile_scene.instantiate()
	proj.global_position = global_position
	var dir = (player.global_position - global_position).normalized()
	proj.setup(dir, monster_data.base_atk if monster_data else 15)
	get_tree().current_scene.add_child(proj)
