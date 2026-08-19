extends CanvasLayer

var hp_talent = preload("res://resources/talents/talent_hp.tres")
var atk_talent = preload("res://resources/talents/talent_atk.tres")
var heal_talent = preload("res://resources/talents/talent_heal.tres")

func _ready() -> void:
	get_tree().paused = true
	$PanelContainer/Margin/VBoxContainer/BtnHP.pressed.connect(_on_select_talent.bind(hp_talent))
	$PanelContainer/Margin/VBoxContainer/BtnATK.pressed.connect(_on_select_talent.bind(atk_talent))
	$PanelContainer/Margin/VBoxContainer/BtnHeal.pressed.connect(_on_select_talent.bind(heal_talent))

func _on_select_talent(talent: TalentData) -> void:
	GameManager.set_starting_talent(talent)
	print("Đã chọn thiên phú: ", talent.talent_name)
	get_tree().paused = false
	queue_free()
