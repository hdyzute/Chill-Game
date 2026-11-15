"""Ghép ảnh cho trang Google Play từ ảnh chụp màn hình và hình linh thú.

Chạy:  python tool/make_store_images.py

Đầu vào trong store/raw/ (đã chuẩn bị sẵn):
- 1_today.png … 5_achievements.png: ảnh chụp màn hình app với dữ liệu mẫu
  (tool/sample_data_test.dart), đã cắt bỏ thanh trạng thái và thanh điều
  hướng của hệ thống.
- pets/*.png: linh thú nền trong suốt, xuất bằng
  `flutter test tool/pet_gallery_test.dart --dart-define=PETS=store/raw/pets`.

Đầu ra:
- store/screenshots/*.png: 1080 × 1920 (9:16), khung điện thoại và chú thích.
  Google Play cần 2–8 ảnh, cạnh dài không quá 2 lần cạnh ngắn, nên không đăng
  thẳng ảnh chụp 1080 × 2400 được.
- store/feature_graphic.png: ảnh bìa 1024 × 500.

Chữ dùng font Roboto đi kèm Flutter SDK (giấy phép Apache 2.0, có dấu tiếng
Việt).
"""

import os

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = os.path.join(ROOT, 'store', 'raw')
SHOTS = os.path.join(ROOT, 'store', 'screenshots')
FONTS = os.environ.get(
    'ROBOTO_DIR', r'C:\src\flutter\bin\cache\artifacts\material_fonts')

TOP = (255, 196, 120)
BOTTOM = (232, 116, 28)
INK = (90, 52, 32)

CAPTIONS = [
    ('1_today.png', 'Thói quen tốt thành phần thưởng',
     'Mỗi việc tốt được xu, giữ chuỗi ngày liên tiếp'),
    ('2_pet.png', 'Nuôi linh thú bằng kỷ luật',
     'Làm việc tốt để trứng nở, lên cấp và tiến hóa'),
    ('3_pet2.png', 'Đánh boss, trồng Linh điền',
     'Việc tốt gây sát thương, cây cho linh vật quý'),
    ('4_history.png', 'Nhìn lại hành trình',
     'Lịch tháng, chuỗi ngày và thống kê theo hệ'),
    ('5_achievements.png', 'Mở khóa thành tựu',
     '24 mốc thành tựu và quà điểm danh mỗi ngày'),
]


def font(weight, size):
    return ImageFont.truetype(os.path.join(FONTS, f'roboto-{weight}.ttf'), size)


def gradient(width, height, top=TOP, bottom=BOTTOM):
    img = Image.new('RGB', (1, height))
    for y in range(height):
        t = y / (height - 1)
        img.putpixel((0, y), tuple(round(a + (b - a) * t)
                                   for a, b in zip(top, bottom)))
    return img.resize((width, height)).convert('RGBA')


def wrap(draw, text, fnt, max_width):
    """Ngắt dòng theo từ cho vừa [max_width]."""
    lines, line = [], ''
    for word in text.split():
        trial = f'{line} {word}'.strip()
        if draw.textlength(trial, font=fnt) <= max_width:
            line = trial
        else:
            lines.append(line)
            line = word
    lines.append(line)
    return lines


def centered_text(img, y, text, fnt, fill, max_width, spacing=1.2,
                  shadow=True):
    """Viết chữ căn giữa từ [y], trả về y sau dòng cuối."""
    draw = ImageDraw.Draw(img)
    size = fnt.size
    for line in wrap(draw, text, fnt, max_width):
        w = draw.textlength(line, font=fnt)
        x = (img.width - w) / 2
        if shadow:
            layer = Image.new('RGBA', img.size, (0, 0, 0, 0))
            ImageDraw.Draw(layer).text((x, y + 4), line, font=fnt,
                                       fill=(120, 50, 0, 110))
            img.alpha_composite(layer.filter(ImageFilter.GaussianBlur(4)))
            draw = ImageDraw.Draw(img)
        draw.text((x, y), line, font=fnt, fill=fill)
        y += size * spacing
    return y


def rounded(img, radius):
    mask = Image.new('L', img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, img.width - 1, img.height - 1], radius=radius, fill=255)
    out = Image.new('RGBA', img.size, (0, 0, 0, 0))
    out.paste(img, (0, 0), mask)
    return out


def phone(screen, height):
    """Ảnh chụp trong khung điện thoại bo góc, cao [height] (cả viền)."""
    bezel = 18
    inner_h = height - 2 * bezel
    inner_w = round(screen.width * inner_h / screen.height)
    screen = rounded(screen.resize((inner_w, inner_h), Image.LANCZOS), 44)
    body = Image.new('RGBA', (inner_w + 2 * bezel, height), (0, 0, 0, 0))
    ImageDraw.Draw(body).rounded_rectangle(
        [0, 0, body.width - 1, body.height - 1], radius=60,
        fill=(48, 34, 28, 255))
    body.alpha_composite(screen, (bezel, bezel))
    return body


def drop_shadow(canvas, box, radius, blur=28, offset=18, alpha=90):
    layer = Image.new('RGBA', canvas.size, (0, 0, 0, 0))
    x0, y0, x1, y1 = box
    ImageDraw.Draw(layer).rounded_rectangle(
        [x0, y0 + offset, x1, y1 + offset], radius=radius,
        fill=(90, 30, 0, alpha))
    canvas.alpha_composite(layer.filter(ImageFilter.GaussianBlur(blur)))


def screenshot(name, title, subtitle):
    W, H = 1080, 1920
    canvas = gradient(W, H)
    # Tiêu đề một dòng: thu nhỏ chữ tới khi vừa.
    size = 70
    probe = ImageDraw.Draw(canvas)
    while size > 54 and probe.textlength(title, font=font('bold', size)) > 980:
        size -= 2
    y = centered_text(canvas, 90 + (70 - size), title, font('bold', size),
                      'white', 1000)
    centered_text(canvas, y + 14, subtitle, font('regular', 40),
                  (255, 255, 255, 235), 940, shadow=False)
    shot = Image.open(os.path.join(RAW, name)).convert('RGBA')
    device = phone(shot, 1480)
    x = (W - device.width) // 2
    top = H - device.height - 50
    drop_shadow(canvas, (x, top, x + device.width, top + device.height), 60)
    canvas.alpha_composite(device, (x, top))
    canvas.convert('RGB').save(os.path.join(SHOTS, name))


def feature_graphic():
    W, H = 1024, 500
    canvas = gradient(W, H, top=(255, 204, 128), bottom=(236, 124, 32))
    # Vầng sáng sau đàn linh thú.
    glow = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse([590, 90, 960, 460],
                                 fill=(255, 250, 240, 90))
    canvas.alpha_composite(glow.filter(ImageFilter.GaussianBlur(60)))

    pets = os.path.join(RAW, 'pets')

    def pet(name, size, cx, bottom):
        img = Image.open(os.path.join(pets, f'{name}.png')).convert('RGBA')
        img = img.resize((size, size), Image.LANCZOS)
        # Hình vẽ chạm đáy ở khoảng 0,9 khung.
        canvas.alpha_composite(img, (round(cx - size / 2),
                                     round(bottom - size * 0.9)))

    pet('water', 240, 650, 395)
    pet('wood', 240, 890, 395)
    pet('fire', 290, 770, 450)
    pet('egg', 140, 560, 470)

    draw = ImageDraw.Draw(canvas)
    title = font('black', 66)
    left = 56
    for i, line in enumerate(['Linh Thú', 'Kỷ Luật']):
        y = 120 + i * 78
        layer = Image.new('RGBA', canvas.size, (0, 0, 0, 0))
        ImageDraw.Draw(layer).text((left, y + 4), line, font=title,
                                   fill=(120, 50, 0, 120))
        canvas.alpha_composite(layer.filter(ImageFilter.GaussianBlur(4)))
        draw = ImageDraw.Draw(canvas)
        draw.text((left, y), line, font=title, fill='white')
    sub = font('medium', 30)
    for i, line in enumerate(['Thói quen tốt nuôi linh thú', 'Mỗi ngày một việc tốt']):
        draw.text((left + 2, 300 + i * 42), line, font=sub,
                  fill=(255, 255, 255, 240) if i == 0 else INK)
    canvas.convert('RGB').save(os.path.join(ROOT, 'store',
                                            'feature_graphic.png'))


def main():
    os.makedirs(SHOTS, exist_ok=True)
    for name, title, subtitle in CAPTIONS:
        screenshot(name, title, subtitle)
    feature_graphic()
    print('Đã ghi', SHOTS, 'và store/feature_graphic.png')


if __name__ == '__main__':
    main()
