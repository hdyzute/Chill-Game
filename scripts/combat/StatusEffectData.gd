class_name StatusEffectData
extends Resource

@export var effect_id: String
@export var effect_name: String              # "Thiêu Đốt", "Làm Chậm"...
@export_enum("dot", "slow", "buff", "debuff") var effect_type: String = "dot"
@export var magnitude: float                  # DoT: dmg/giây. Slow: % giảm tốc (0.5 = giảm 50%)
@export var duration: float                   # thời gian hiệu lực (giây)
@export var tick_interval: float = 1.0        # riêng cho DoT: khoảng cách giữa các lần trừ máu
@export var vfx_color: Color = Color.WHITE    # màu hiệu ứng nhấp nháy
