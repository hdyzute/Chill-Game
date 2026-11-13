# Kế hoạch: App thói quen nuôi linh thú

Tên tạm: **Linh Thú Kỷ Luật** (đổi sau)

## 1. Ý tưởng cốt lõi

- Người dùng tự đặt thói quen. Hoàn thành thì nhận **linh vật** và **xu**, cho linh thú **hấp thụ** để lớn lên và tiến hóa.
- Nuôi **một con linh thú** thay cho nhân vật người chơi kiểu Habitica.
- **Điểm khác biệt:** mỗi thói quen thuộc một **hệ**. Linh thú tiến hóa theo nhánh của hệ mà bạn làm nhiều nhất, nên con pet phản ánh cuộc sống thật của bạn.
- **Điều kiện tiến hóa kép** (giữ từ game cũ): linh thú đủ cấp **và** người dùng đạt mốc streak.
- Giọng điệu nhẹ nhàng: pet **không bao giờ chết**, chỉ buồn hoặc mệt rồi hồi lại khi bạn quay lại.

## 2. Học từ Habitica (đã đọc code: `scoreTask.js`, `cron.js`, `randomDrop.js`, `crit.js`)

| Cơ chế Habitica | Cách hoạt động | Mình áp dụng |
|---|---|---|
| 4 loại task | Habit (+/−, làm lúc nào cũng được), Daily (theo lịch, có streak), To-Do (một lần, có checklist), Reward (phần thưởng tự đặt, mua bằng vàng) | Giữ cả 4. **Phần thưởng tự đặt** rất hay: "xem 1 tập phim = 30 xu" |
| Giá trị task | Mỗi task có `value`. Phần thưởng mỗi lần = `0.9747^value`: task bị bỏ bê lâu thì làm lại được thưởng nhiều, task làm liên tục thì giảm dần. Value giới hạn trong [−47, 21] | Giữ bản đơn giản hóa. Hiển thị màu task (đỏ → xanh) |
| Độ khó | Trivial 0.1, Easy 1, Medium 1.5, Hard 2, nhân vào mọi phần thưởng | Giữ: Dễ / Vừa / Khó |
| Vàng và EXP | `EXP = delta × độ khó × crit × 6`, `vàng = delta × độ khó × crit × (1 + streak/100)` | Giữ công thức, chỉnh số sau |
| Bạo kích | 3% cơ hội, nhân ×1.5 trở lên. Bất ngờ = vui | "Linh khí bạo phát!": x2 linh vật |
| Rơi đồ | Tỉ lệ phụ thuộc value và độ khó, **giới hạn ~5 món/ngày** để chống spam tick. Thức ăn 40%, trứng 30%, thuốc nở 30% (có độ hiếm) | Linh vật theo hệ, có độ hiếm, có giới hạn mỗi ngày |
| Sang ngày mới (cron) | Giờ bắt đầu ngày tùy chỉnh (cho người thức khuya). Daily bị bỏ lỡ: trừ HP, reset streak. Checklist làm được một phần thì phạt ít hơn | Giữ giờ bắt đầu ngày. Bỏ lỡ: giảm **tâm trạng** pet thay vì HP |
| Chế độ nghỉ (Inn) | Tạm dừng mọi hình phạt khi đi du lịch hay ốm | Giữ: "Linh thú bế quan" |
| Boss | Cả ngày làm task thì tích sát thương (`progress.up`). Cuối ngày gây sát thương lên boss; daily bỏ lỡ thì boss đánh lại **cả nhóm** | Giai đoạn 4: boss một mình trước, nhóm sau (cần server) |
| Task attribute | Mỗi task gắn STR/INT/CON/PER, làm task nào thì tăng chỉ số đó | **Chính là ý tưởng "hệ" của mình**, nhưng biến thành hình dạng pet nhìn thấy được |
| Thành tựu | Streak mỗi 21 ngày, Perfect Day (làm hết daily), quà điểm danh theo bậc | Giữ, đổi tên cho hợp chủ đề |
| Bỏ tick | Bỏ tick thì hoàn lại chính xác phần thưởng (tránh lỗi tick nhầm) | Bắt buộc phải có |

## 3. Cơ chế của mình (v1)

**Hệ** (dựa theo ngũ hành, MVP làm 3 hệ trước):

| Hệ | Nhóm thói quen | Linh vật |
|---|---|---|
| Hỏa | Vận động, sức khỏe | Hỏa Linh Quả |
| Thủy | Học tập, đọc sách | Thủy Tinh Lộ |
| Mộc | Tinh thần: thiền, ngủ sớm, không điện thoại | Mộc Linh Chi |
| Kim, Thổ | Công việc/tài chính, nhà cửa/quan hệ | Làm sau |

**Vòng đời linh thú (MVP: 1 loài)**
1. Ký khế ước: chọn trứng, đặt tên, tạo 3 thói quen đầu tiên.
2. Trứng → **Ấu thú** ngay khi có việc tốt đầu tiên sau khi ký khế ước (chờ lâu thì người mới dễ bỏ app).
3. Ấu thú → **Trưởng thành**: một trong 3 nhánh (Hỏa / Thủy / Mộc) theo điểm hệ cao nhất, cần cấp ≥ 5 **và** chuỗi ≥ 7 ngày liên tiếp có việc tốt. Người dùng bấm "Tiến hóa" để chốt nhánh.
4. Sau này: Linh Thú → Yêu Thú → Thánh Thú → Thần Thú (mốc streak 30 / 100 / 365).

**Chỉ số pet:** cấp, EXP, điểm từng hệ, **tâm trạng** (vui / bình thường / buồn / mệt; ảnh hưởng animation và câu thoại), độ no (chưa làm).

**Lý do mở app mỗi ngày:** cho ăn, xoa đầu pet, quà nhỏ ngẫu nhiên, câu thoại theo tâm trạng, sau này thêm linh điền.

**Chống phạt quá tay:** có **Bùa Giữ Streak**, kiếm được bằng thành tựu, không chỉ bán bằng tiền.

## 4. Công nghệ

| Phần | Chọn | Lý do |
|---|---|---|
| Framework | **Flutter** (Dart) | Một code chạy cả Android và iOS, UI đẹp, AI viết tốt |
| State | Riverpod | Phổ biến, dễ test |
| Lưu dữ liệu | Drift (SQLite) trên máy | Offline trước, chưa cần tài khoản |
| Thông báo | `flutter_local_notifications` | Nhắc giờ theo lịch |
| Widget màn hình chính | `home_widget` | Giai đoạn 3 |
| Animation pet | Rive (hoặc ảnh PNG tĩnh trước) | Một file, nhiều trạng thái |
| Server (sau này) | Supabase hoặc Firebase | Đồng bộ, boss theo nhóm, mua hàng |

Làm **Android trước**: máy đã có Android SDK. iOS cần máy Mac hoặc dịch vụ build trên cloud.

## 5. Lộ trình

**Giai đoạn 0: Chuẩn bị**
- [x] Lưu game Ngự Thú cũ vào nhánh `archive/ngu-thu-game`, cập nhật lại `CLAUDE.md`
- [x] Cài Flutter SDK (dùng JDK có sẵn trong Android Studio), chạy `flutter doctor`
- [x] `flutter create`, cấu trúc thư mục, khung 4 tab
- [x] Chấp nhận Android licenses, chạy được trên điện thoại hoặc emulator

**Giai đoạn 1: App thói quen dùng được (chưa có pet)**
- [x] Tạo / sửa / xóa 4 loại task, độ khó, hệ, lịch lặp cho daily (bước 1.1)
- [x] Tick / bỏ tick (hoàn lại chính xác), streak, xu, bạo kích, mua phần thưởng (bước 1.2)
- [x] Thói quen tốt có "số lần mỗi ngày" (mặc định 1) để không bấm liên tục cày xu
- [x] Giờ bắt đầu ngày, xử lý sang ngày mới, đứt chuỗi khi bỏ lỡ, chế độ bế quan, cất việc cần làm đã xong (bước 1.3)
- [x] Thông báo nhắc giờ cho daily và thói quen, tự bỏ qua khi đã làm xong (bước 1.4)
- [x] Lịch sử: lịch tháng tô đậm theo số việc tốt, chi tiết từng ngày, chuỗi ngày liên tiếp, thống kê tháng theo hệ (bước 1.5)
- ✅ Kiểm tra: bạn tự dùng thật 1 tuần (bắt đầu 4/11/2026, chạy song song với Giai đoạn 2)

**Giai đoạn 2: Linh thú**
- [x] Màn hình khế ước (đặt tên, nhận trứng), trứng nở từ việc tốt đầu tiên, màn hình nhà của pet với hình tạm (bước 2.1). Chưa có bước chọn trứng vì MVP chỉ có 1 loài
- [x] Linh vật rơi khi làm việc tốt (theo hệ, Dễ 50% / Vừa 75% / Khó 100%, 10% ra bản "ngàn năm"), bạo kích rơi 2 món, tối đa 5 món mỗi ngày, túi linh vật trong tab Linh thú; hoàn tác lấy lại đúng món (bước 2.2). Xu, bạo kích và phần thưởng tự đặt đã có từ bước 1.2
- [x] Hấp thụ linh vật → EXP và điểm hệ (thường +10 EXP +1 điểm, ngàn năm +30 EXP +3 điểm; cấp 2/3/4/5 ở 20/60/120/200 EXP); tâm trạng tính từ việc tốt, việc xấu và bế quan; tiến hóa theo nhánh. Bỏ tick sau khi đã hấp thụ thì trừ lại EXP của món đó (bước 2.3)
- ✅ Kiểm tra: 3–5 người bạn dùng thử 2 tuần, xem họ có mở app đều không

**Giai đoạn 3: Linh điền + widget**
- [x] Gieo hạt, cây lớn theo thời gian thực, thu hoạch ra linh vật (bước 3.1): 3 ô đất trong tab Linh thú, hạt 15 xu, chín sau 8 giờ, mỗi việc tốt cùng hệ giúp chín sớm 1 giờ, thu 2 linh vật cùng hệ (không tính vào giới hạn 5 món/ngày)
- [ ] Widget hiện pet và việc hôm nay

**Giai đoạn 4: Bí cảnh và boss (một mình)**
- [ ] Boss có HP; task hoàn thành gây sát thương lúc sang ngày; bỏ lỡ thì boss tấn công tâm trạng pet
- [ ] Thành tựu, quà điểm danh

**Giai đoạn 5: Phát hành**
- [ ] Icon, ảnh store, chính sách quyền riêng tư
- [ ] Tài khoản Google Play Developer (phí một lần). Tài khoản cá nhân mới phải chạy closed testing với một số người test trong 14 ngày; kiểm tra lại yêu cầu hiện tại trước khi nộp
- [ ] Phát hành bản 1.0

**Giai đoạn 6: Kiếm tiền và online**
- [ ] Kim cương: chỉ cho đồ trang trí, trứng mới, giao diện. **Không bán tiến hóa hay streak**
- [ ] Đồng bộ tài khoản, boss theo nhóm, bạn bè

## 6. Hình ảnh (nút thắt lớn nhất)

Asset tối thiểu cho MVP:
- 1 quả trứng (2–3 trạng thái nứt)
- Ấu thú × 4 tâm trạng
- 3 dạng trưởng thành × 4 tâm trạng
- Khoảng 6 icon linh vật, icon xu, nền nhà pet

Nguồn: AI tạo ảnh rồi chỉnh tay (giữ **một phong cách chibi thống nhất**), asset pack trên itch.io (kiểm tra giấy phép thương mại), hoặc thuê vẽ khi có tiền. Sprite rồng trong repo cũ chỉ dùng lại được nếu rõ nguồn và giấy phép.

## 7. Rủi ro

- **Scope phình to:** chỉ làm giai đoạn tiếp theo khi giai đoạn trước đã dùng thật.
- **Hình ảnh không đồng bộ:** chốt style guide (màu, nét, tỉ lệ đầu/thân) trước khi tạo hàng loạt.
- **Thông báo Android:** chế độ tiết kiệm pin và quyền exact alarm có thể làm nhắc giờ bị trễ, cần test trên máy thật.
- **Không dùng code hoặc hình của Habitica:** code theo GPL v3, hình theo CC BY-NC-SA. Chỉ học cơ chế.
