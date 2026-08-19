# PROJECT SPEC: Ngự Thú 2D Pixel (Mobile) — Vertical Slice v0.2
### Cơ chế lõi: Co-leveling (Người chơi + Sủng thú cùng trưởng thành) + Thiên Phú

## Mục tiêu cho Antigravity
Bạn là AI coding agent sẽ trực tiếp code project này trong Godot 4 (GDScript). Nhiệm vụ đầu tiên KHÔNG phải làm full game, mà là dựng **1 Vertical Slice chơi được trong 5-10 phút**, đúng theo scope MVP mô tả bên dưới. Ưu tiên: chạy được, ít bug, cấu trúc code sạch để mở rộng sau — không cần tối ưu performance sớm.

**Điểm khác biệt cốt lõi của game so với thể loại "ngự thú/monster tamer" thông thường:** người chơi KHÔNG đứng ngoài quản lý — người chơi và sủng thú cùng nhận EXP, cùng lên cấp, nhưng theo 2 đường cong khác nhau (người chơi tăng stats rất chậm, sủng thú tăng nhanh và mạnh). Sủng thú chỉ tiến hóa khi người chơi đạt mốc cấp độ nhất định VÀ có đủ vật liệu tiến hóa (rơi ra từ quái trong phó bản). Người chơi bù lại phần stats yếu bằng hệ thống trang bị.

---

## 1. Engine & Stack
- **Engine:** Godot 4.x (bản stable mới nhất)
- **Ngôn ngữ:** GDScript
- **Nền tảng target:** Android/iOS export (portrait mode, touch control)
- **Resolution thiết kế:** 720x1280 (portrait), pixel-perfect scaling (Viewport stretch mode = canvas_items, tối ưu cho pixel art)
- **Data format:** Godot Resource (.tres) hoặc JSON — dùng Resource-based (Custom Resource class trong GDScript) cho Monster Data để dễ mở rộng, KHÔNG hardcode stats trong script.

## 2. Cấu trúc thư mục project
```
res://
  scenes/
    main/           # Main menu, game manager scene
    map/             # Overworld map, tile-based
    combat/          # Combat scene
    ui/              # UI screens (Mắt Thần, inventory, evolution)
  scripts/
    core/            # Autoload singletons (GameManager, MonsterDatabase)
    monster/         # Monster class, evolution logic
    combat/          # Combat logic, AI behavior
    ui/              # UI controllers
  resources/
    monsters/        # MonsterData .tres files (1 file / loài)
    items/           # ItemData .tres files
  assets/
    sprites/
      monsters/
      tiles/
      ui/
    audio/
```

## 3. Scope MVP (Vertical Slice) — CHỈ làm đúng phần này trước
KHÔNG implement gacha, monetization, base-building, hay >1 hệ nguyên tố / >1 nhánh tiến hóa ở bản này. Chỉ 1 chuỗi tiến hóa duy nhất, 1 hệ duy nhất, để test cảm giác của cơ chế co-leveling trước khi nhân bản ra nhiều hệ. Cụ thể:

1. **1 nhân vật người chơi** di chuyển 2D top-down trên 1 map nhỏ (TileMap ~20x20 tile, tile 16x16px).
2. **Màn hình chọn Thiên Phú lúc bắt đầu game** (chỉ cần 2-3 lựa chọn dạng thẻ bài đơn giản, mỗi thiên phú cho 1 passive bonus khác nhau — vd "+10% ATK" / "+15% Max HP" / "Hồi 5% HP mỗi lần lên cấp"). Chọn xong lưu vào PlayerData, không cho đổi lại.
3. **1 con thú khởi đầu** đi theo sau nhân vật (follow behavior đơn giản, theo hướng player với offset/delay).
4. **Cơ chế Co-leveling:** cả người chơi và thú cùng nhận EXP khi thắng trận (xem mục 4b). Lên cấp độc lập theo 2 growth rate khác nhau — người chơi tăng stat rất ít mỗi cấp, thú tăng nhiều.
5. **Cơ chế tiến hóa có điều kiện kép:** thú CHỈ tiến hóa khi (a) người chơi đạt cấp mốc quy định (MVP dùng mốc thấp để test nhanh, ví dụ cấp 5 thay vì 20-30 như thiết kế thật) VÀ (b) người chơi có đủ vật liệu tiến hóa. Khi đủ cả 2 điều kiện → hiện nút "Tiến hóa" trên UI, bấm vào trigger đổi sprite (Cấp 1 → Cấp 2) + shader palette swap.
6. **Phó bản cày cấp đơn giản:** 1 khu vực nhỏ trên map có 2-3 quái hoang dã, đánh thắng → cả người chơi và thú nhận EXP, có tỉ lệ rơi vật liệu tiến hóa.
7. **1 trận chiến** với Monster hoang dã: combat semi-auto — thú tự đánh theo AI cơ bản (state machine: Idle → Attack → Cooldown), người chơi có 1 nút kích hoạt "Kỹ năng Khế Ước" (vd hồi máu/buff giáp tạm thời) — sức mạnh skill này SCALE theo stats người chơi (bao gồm cả trang bị).
8. **Hệ thống trang bị tối giản:** 1 slot vũ khí + 1 slot giáp cho người chơi, mỗi item cộng thẳng vào ATK/DEF/HP. Không cần crafting/upgrade ở MVP — chỉ nhặt trang bị có sẵn trong map hoặc rơi từ quái.
9. **UI:** thanh máu + thanh EXP người chơi/thú, nút skill, bảng nhân vật hiển thị stats (base + bonus từ trang bị), màn hình kết quả thắng/thua.

## 4. Data Schema

### 4a. MonsterData (Custom Resource)
```gdscript
class_name MonsterData
extends Resource

@export var monster_id: String
@export var monster_name: String
@export var element: String            # Kim/Mộc/Thủy/Hỏa/Thổ...
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
@export var evolution_player_level_required: int  # mốc cấp NGƯỜI CHƠI phải đạt (MVP: 5, thiết kế thật: 20-30)
```

### 4b. PlayerData (Custom Resource / Autoload state)
```gdscript
class_name PlayerData
extends Resource

@export var level: int = 1
@export var exp: int = 0
@export var exp_to_next_level: int = 100   # dùng công thức tăng dần, vd exp_to_next = 100 * level^1.2

# Base stats — GROWTH THẤP có chủ đích, vì con người yếu hơn thú tổng quan
@export var base_hp: int = 50
@export var base_atk: int = 5
@export var base_def: int = 3
@export var hp_growth_per_level: int = 3    # THẤP so với thú
@export var atk_growth_per_level: int = 1
@export var def_growth_per_level: int = 1

@export var talent_id: String              # thiên phú đã chọn lúc bắt đầu, không đổi được
@export var equipped_weapon_id: String     # rỗng = chưa trang bị
@export var equipped_armor_id: String

# Hàm tính stat tổng = base + growth*level + bonus từ trang bị + bonus từ thiên phú
```

### 4c. TalentData (Thiên Phú — Custom Resource)
```gdscript
class_name TalentData
extends Resource

@export var talent_id: String
@export var talent_name: String
@export var description: String
@export var stat_type: String       # "atk_percent" / "hp_percent" / "heal_on_levelup"
@export var value: float            # vd 0.10 = +10%
```
MVP chỉ cần 2-3 TalentData mẫu, chọn 1 lần ở màn hình bắt đầu game, lưu vào PlayerData, ảnh hưởng vĩnh viễn tới công thức tính stat.

### 4d. EquipmentData (Custom Resource)
```gdscript
class_name EquipmentData
extends Resource

@export var equip_id: String
@export var equip_name: String
@export var slot_type: String       # "weapon" / "armor"
@export var atk_bonus: int
@export var def_bonus: int
@export var hp_bonus: int
```
MVP chỉ cần 1 vũ khí mẫu + 1 giáp mẫu, cộng thẳng số vào stat cuối, không cần rarity/upgrade.

## 5. Combat Logic — chi tiết cho AI agent code
- State machine đơn giản dùng enum: `IDLE, MOVING, ATTACKING, SKILL_ACTIVE, DEAD`
- Thú tự động: mỗi X giây (dựa trên ATK speed) → tấn công quái nếu trong tầm. ATK/HP/DEF của thú tính từ `MonsterData` base + growth*level (KHÔNG cộng trang bị — trang bị chỉ dành cho người chơi).
- Người chơi (Ngự Thú Sư) đứng ngoài combat, chỉ có 1 nút skill với cooldown riêng — KHÔNG di chuyển trong combat ở bản MVP này.
- **Skill Khế Ước scale theo stats người chơi:** ví dụ hồi máu = `player_total_atk * 2`, buff giáp = `player_total_def * 1.5`. Vì vậy trang bị và thiên phú của người chơi ảnh hưởng trực tiếp tới hiệu quả skill dù người chơi không tự đánh — đây là cách bù đắp cho việc stats gốc người chơi thấp.
- Combat kết thúc khi HP một bên về 0 → hiện màn hình kết quả. Nếu thắng → cả người chơi và thú nhận EXP (xem mục 5b) + roll tỉ lệ rơi vật liệu tiến hóa.

## 5b. Co-leveling — EXP & Level Up
- Khi thắng 1 trận, gọi `PlayerData.add_exp(amount)` và `MonsterInstance.add_exp(amount)` CÙNG LÚC với cùng 1 lượng EXP gốc (có thể nhân hệ số khác nhau nếu cần cân bằng sau này, nhưng MVP dùng chung 1 con số).
- Mỗi bên tự kiểm tra ngưỡng lên cấp riêng (`exp >= exp_to_next_level`) và tự tính lại stats theo growth rate riêng của mình — đây là lý do 2 class data tách biệt (PlayerData vs MonsterData) dù cùng nhận 1 nguồn EXP.
- Không cần đồng bộ cấp độ giữa 2 bên — thú có thể cấp cao hơn hoặc thấp hơn người chơi tùy growth rate, đó là chủ đích thiết kế (thú luôn mạnh hơn về số tuyệt đối).

## 5c. Evolution Gate (điều kiện kép)
- Hàm `can_evolve(monster_instance, player_data) -> bool` trả về true CHỈ KHI:
  1. `player_data.level >= monster_instance.data.evolution_player_level_required`
  2. `player_data.inventory.has(monster_instance.data.evolution_item_id)`
- UI hiển thị nút "Tiến hóa" (mờ/disable nếu chưa đủ điều kiện, kèm tooltip báo thiếu gì — vd "Cần đạt cấp 5" hoặc "Cần thêm vật liệu X").
- Khi bấm tiến hóa: trừ vật liệu khỏi inventory, đổi `monster_instance.data` sang `evolves_into`, trigger đổi sprite + shader palette swap như cũ.

## 6. Palette Swap cho tiến hóa (kỹ thuật)
- Dùng 1 Shader đơn giản (`palette_swap.gdshader`) nhận input là 1 Gradient texture hoặc màu để remap màu sprite gốc.
- Base sprite giữ nguyên hình dạng, chỉ đổi tông màu qua shader parameter khi tiến hóa — không cần vẽ lại sprite cho mỗi biến thể màu.

## 7. Quy ước code cho Antigravity
- Dùng Autoload singleton `GameManager` cho state toàn game (player data, current monster, inventory).
- Dùng Autoload `MonsterDatabase` để load tất cả `.tres` trong `res://resources/monsters/` lúc khởi động.
- Comment tiếng Việt hoặc tiếng Anh đều được, nhưng tên biến/hàm/class dùng tiếng Anh (chuẩn GDScript convention).
- Mỗi hệ thống (Care, Combat, Space) tách riêng file/class, tránh 1 script làm tất cả (God Object).
- Không cần viết unit test ở giai đoạn vertical slice này.

## 8. Checklist thứ tự triển khai (để Antigravity làm tuần tự)
1. [ ] Setup project Godot, cấu hình viewport/resolution cho mobile portrait.
2. [ ] Tạo PlayerData, TalentData, MonsterData, EquipmentData resource classes.
3. [ ] Màn hình chọn Thiên Phú lúc bắt đầu (2-3 lựa chọn), lưu vào PlayerData.
4. [ ] TileMap map nhỏ + player movement (touch/virtual joystick).
5. [ ] MonsterData mẫu (loài khởi đầu, 2 cấp tiến hóa, growth rate cao) + Follow behavior cho thú theo player.
6. [ ] Khu vực phó bản nhỏ với 2-3 quái hoang dã trên map.
7. [ ] Combat scene: state machine cho thú + quái, skill Khế Ước scale theo stats người chơi.
8. [ ] Co-leveling: cả player và thú nhận EXP sau trận thắng, tự tính lại stats theo growth rate riêng.
9. [ ] Item rơi từ quái (vật liệu tiến hóa) + hệ thống inventory tối giản.
10. [ ] Evolution Gate: hàm `can_evolve()` kiểm tra điều kiện kép, UI nút Tiến hóa (đổi sprite + shader palette swap).
11. [ ] Trang bị: 1 vũ khí + 1 giáp mẫu, nhặt được trong map, cộng thẳng vào stats người chơi.
12. [ ] UI tổng hợp: thanh HP/EXP người chơi & thú, bảng nhân vật (base + bonus trang bị/thiên phú), màn hình thắng/thua.
13. [ ] Test full loop trên Android build/emulator: chọn thiên phú → cày phó bản → lên cấp cùng thú → đủ điều kiện → tiến hóa → trang bị đồ nhặt được → thấy skill mạnh hơn rõ rệt.

---
**Lưu ý cho Antigravity:** Đây là bản v0.2 vertical slice — mục tiêu là CẢM NHẬN ĐƯỢC cơ chế co-leveling (2 đường cong tăng trưởng khác nhau) và evolution gate (điều kiện kép) có tạo cảm giác "được đầu tư" hay không, không phải làm đẹp hay đầy đủ nội dung. Placeholder sprite (hình vuông/tròn màu) chấp nhận được cho mọi bước nếu asset pixel art chưa sẵn sàng. Mốc cấp tiến hóa (`evolution_player_level_required`) để THẤP ở MVP (vd 5) chỉ để test nhanh — con số thiết kế thật (20-30) sẽ điều chỉnh sau khi loop được xác nhận là vui.
