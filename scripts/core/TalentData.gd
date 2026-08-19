class_name TalentData
extends Resource

@export var talent_id: String
@export var talent_name: String
@export var description: String
@export var stat_type: String       # "atk_percent" / "hp_percent" / "heal_on_levelup"
@export var value: float            # vd 0.10 = +10%
