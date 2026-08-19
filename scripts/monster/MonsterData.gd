class_name MonsterData
extends Resource

@export var monster_id: String
@export var monster_name: String
@export var is_boss: bool = false
@export var element: String            # Kim/Mộc/Thủy/Hỏa/Thổ...
@export var on_hit_effects: Array[StatusEffectData] = []
@export var base_hp: int
@export var base_atk: int
@export var base_def: int
@export var hp_growth_per_level: int    # CAO — thú tăng mạnh mỗi cấp
@export var atk_growth_per_level: int
@export var def_growth_per_level: int
@export var evolution_stage: int        # 1, 2, 3
@export var sprite_frames: SpriteFrames
@export var evolves_into: String        # monster_id tiếp theo, rỗng nếu max
@export var evolution_item_id: String   # vật liệu cần để tiến hóa (rơi từ phó bản)
@export var evolution_player_level_required: int  # mốc cấp NGƯỜI CHƠI phải đạt
@export var exp_reward: int = 50
@export var drop_rate_evo_stone: float = 0.5
