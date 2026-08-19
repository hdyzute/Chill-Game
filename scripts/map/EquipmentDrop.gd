extends Area2D

@export var equip_data: EquipmentData
@export var is_evo_stone: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if is_evo_stone or not equip_data:
			GameManager.player_data.add_item("evo_stone")
			GameManager.evo_stones_dropped += 1
			print("Nhặt được: Đá Tiến Hóa")
			queue_free()
			return
		
		# Auto-equip
		GameManager.player_data.equip(equip_data)
		print("Đã trang bị: ", equip_data.equip_name)
		queue_free()
