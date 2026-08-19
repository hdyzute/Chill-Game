extends Node2D
class_name MonsterSpawner

@export var monster_scene: PackedScene = preload("res://scenes/map/WildMonster.tscn")
@export var monster_data: MonsterData
@export var respawn_time: float = 5.0

var current_monster: Node2D = null
@onready var respawn_timer: Timer = $RespawnTimer

func _ready() -> void:
	if has_node("EditorIcon"):
		$EditorIcon.hide()
	
	if respawn_timer:
		respawn_timer.wait_time = respawn_time
		respawn_timer.timeout.connect(_on_respawn_timer_timeout)
	
	# Sinh con quái đầu tiên sau khi khởi tạo xong (để tránh lỗi xung đột Godot Tree)
	call_deferred("spawn_monster")

func spawn_monster() -> void:
	if not monster_scene:
		print("Lỗi: Spawner chưa được gán Scene quái!")
		return
	if not monster_data:
		print("CẢNH BÁO: Spawner chưa gán Monster Data! Quái sinh ra sẽ không thể đánh được.")
		
	var scn = monster_scene
	if randf() < 0.3:
		var ranged_scn = load("res://scenes/map/RangedSlime.tscn")
		if ranged_scn:
			scn = ranged_scn
			
	current_monster = scn.instantiate()
	
	# Gán dữ liệu cho quái
	if "monster_data" in current_monster:
		current_monster.monster_data = monster_data
		
	# Gắn quái vật vào tree làm con của map (parent của Spawner) để không bị kế thừa scale của Spawner
	if get_parent():
		get_parent().add_child(current_monster)
	else:
		add_child(current_monster)
	current_monster.global_position = global_position
	
	# Lắng nghe sự kiện quái bị xóa (chết) để đếm ngược respawn
	current_monster.tree_exited.connect(_on_monster_died)

func _on_monster_died() -> void:
	print("Spawner: Quái đã chết, bắt đầu đếm ngược ", respawn_time, " giây...")
	current_monster = null
	if respawn_timer:
		respawn_timer.start()

func _on_respawn_timer_timeout() -> void:
	print("Spawner: Hồi sinh quái vật!")
	spawn_monster()
