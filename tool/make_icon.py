"""Vẽ icon tạm của app: quả trứng linh thú nứt, ba đốm màu ba hệ, nền cam.

Chạy lại sau khi sửa:  python tool/make_icon.py
rồi:                   dart run flutter_launcher_icons

Ghi ra assets/icon/ (icon đầy đủ, lớp trước và lớp nền của icon thích ứng,
bản đơn sắc cho icon theo chủ đề của Android 13) và store/icon_512.png cho
Google Play. Vẽ ở 4 lần kích thước rồi thu nhỏ để viền mịn.
"""

import math
import os

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'assets', 'icon')
STORE = os.path.join(ROOT, 'store')

SIZE = 1024
SS = 4  # hệ số vẽ phóng to
BIG = SIZE * SS

ORANGE_LIGHT = (255, 184, 92)
ORANGE_DARK = (226, 104, 20)
SHELL = (255, 248, 234)
SHELL_SHADE = (240, 222, 196)
CRACK = (110, 62, 30)
FIRE = (229, 83, 61)
WATER = (47, 127, 216)
WOOD = (62, 155, 79)


def egg_points(cx, cy, h, steps=720):
    """Đường viền quả trứng cao [h]: đầu trên nhỏ hơn đầu dưới."""
    rx, ry = h * 0.39, h / 2
    pts = []
    for i in range(steps):
        t = 2 * math.pi * i / steps
        x = rx * math.sin(t) * (1 - 0.16 * math.cos(t))
        y = -ry * math.cos(t)
        pts.append((cx + x, cy + y))
    return pts


def egg_mask(cx, cy, h):
    mask = Image.new('L', (BIG, BIG), 0)
    ImageDraw.Draw(mask).polygon(egg_points(cx, cy, h), fill=255)
    return mask


def crack_points(cx, cy, h):
    """Đường nứt zigzag ngang thân trứng, hơi trên giữa."""
    w = h * 0.9
    y0 = cy - h * 0.06
    xs = [cx - w / 2 + w * i / 8 for i in range(9)]
    return [(x, y0 + (h * 0.055 if i % 2 else -h * 0.035)) for i, x in enumerate(xs)]


def sparkle(draw, cx, cy, r, fill):
    """Ngôi sao bốn cánh."""
    k = r * 0.22
    draw.polygon([
        (cx, cy - r), (cx + k, cy - k), (cx + r, cy), (cx + k, cy + k),
        (cx, cy + r), (cx - k, cy + k), (cx - r, cy), (cx - k, cy - k),
    ], fill=fill)


def draw_egg(h, cx=BIG / 2, cy=BIG / 2):
    """Lớp trứng trên nền trong suốt, kích thước BIG."""
    layer = Image.new('RGBA', (BIG, BIG), (0, 0, 0, 0))
    mask = egg_mask(cx, cy, h)

    # Bóng đổ mềm dưới trứng.
    shadow = Image.new('L', (BIG, BIG), 0)
    ImageDraw.Draw(shadow).ellipse(
        [cx - h * 0.3, cy + h * 0.44, cx + h * 0.3, cy + h * 0.54], fill=90)
    shadow = shadow.filter(ImageFilter.GaussianBlur(h * 0.03))
    layer.paste((120, 50, 0, 255), (0, 0), shadow)

    # Vỏ: màu kem, nửa phải tối hơn chút.
    shell = Image.new('RGBA', (BIG, BIG), SHELL + (255,))
    shade = Image.new('L', (BIG, BIG), 0)
    ImageDraw.Draw(shade).ellipse(
        [cx - h * 0.05, cy - h * 0.6, cx + h * 0.75, cy + h * 0.65], fill=255)
    shade = shade.filter(ImageFilter.GaussianBlur(h * 0.08))
    shell.paste(SHELL_SHADE + (255,), (0, 0), shade)
    d = ImageDraw.Draw(shell)

    # Ba đốm ba hệ.
    for (dx, dy, r, color) in [
        (-0.17, 0.2, 0.11, FIRE),
        (0.15, 0.3, 0.085, WATER),
        (0.05, -0.33, 0.07, WOOD),
        (0.21, -0.17, 0.045, WATER),
        (0.22, 0.05, 0.05, FIRE),
        (-0.02, 0.4, 0.04, WOOD),
    ]:
        x, y, rr = cx + dx * h, cy + dy * h, r * h
        d.ellipse([x - rr, y - rr, x + rr, y + rr], fill=color)

    # Vệt sáng trên bên trái.
    hl = Image.new('L', (BIG, BIG), 0)
    ImageDraw.Draw(hl).ellipse(
        [cx - h * 0.27, cy - h * 0.38, cx - h * 0.13, cy - h * 0.16], fill=200)
    hl = hl.filter(ImageFilter.GaussianBlur(h * 0.015))
    shell.paste((255, 255, 255, 255), (0, 0), hl)

    # Đường nứt.
    d.line(crack_points(cx, cy, h), fill=CRACK, width=int(h * 0.028),
           joint='curve')

    layer.paste(shell, (0, 0), mask)

    # Viền trứng: chấm bút tròn dọc đường viền, để nét đều và không gai.
    outline = Image.new('L', (BIG, BIG), 0)
    od = ImageDraw.Draw(outline)
    r = h * 0.011
    for (x, y) in egg_points(cx, cy, h, steps=1440):
        od.ellipse([x - r, y - r, x + r, y + r], fill=255)
    layer.paste(CRACK + (255,), (0, 0), outline)

    # Lấp lánh quanh trứng.
    d = ImageDraw.Draw(layer)
    sparkle(d, cx + h * 0.42, cy - h * 0.36, h * 0.09, (255, 255, 255, 255))
    sparkle(d, cx + h * 0.55, cy - h * 0.16, h * 0.045, (255, 245, 200, 255))
    sparkle(d, cx - h * 0.47, cy - h * 0.05, h * 0.05, (255, 255, 255, 230))
    return layer


def background():
    """Nền cam chuyển màu tỏa tròn, sáng ở giữa trên."""
    small = 256
    bg = Image.new('RGB', (small, small))
    px = bg.load()
    for y in range(small):
        for x in range(small):
            dist = math.hypot(x - small * 0.45, y - small * 0.35) / (small * 0.9)
            t = min(1.0, dist)
            px[x, y] = tuple(
                round(a + (b - a) * t) for a, b in zip(ORANGE_LIGHT, ORANGE_DARK))
    return bg.resize((BIG, BIG), Image.BICUBIC).convert('RGBA')


def shrink(img, size=SIZE):
    return img.resize((size, size), Image.LANCZOS)


def monochrome(h, cy):
    """Bóng trứng trắng, đường nứt khoét trống, cho icon theo chủ đề."""
    cx = BIG / 2
    mask = egg_mask(cx, cy, h)
    ImageDraw.Draw(mask).line(crack_points(cx, cy, h), fill=0,
                              width=int(h * 0.045), joint='curve')
    white = Image.new('RGBA', (BIG, BIG), (255, 255, 255, 0))
    white.putalpha(mask)
    return white


def main():
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(STORE, exist_ok=True)

    bg = background()
    shrink(bg).convert('RGB').save(os.path.join(OUT, 'background.png'))

    # Icon thích ứng: phần nhìn thấy chắc chắn là hình tròn giữa, đường kính
    # 66/108 khung, nên trứng nhỏ hơn.
    fg = draw_egg(BIG * 0.44, cy=BIG * 0.51)
    shrink(fg).save(os.path.join(OUT, 'foreground.png'))
    shrink(monochrome(BIG * 0.44, cy=BIG * 0.5)).save(
        os.path.join(OUT, 'monochrome.png'))

    # Icon đầy đủ (Android cũ, Google Play): trứng to hơn.
    full = bg.copy()
    full.alpha_composite(draw_egg(BIG * 0.68, cy=BIG * 0.52))
    shrink(full).convert('RGB').save(os.path.join(OUT, 'icon.png'))
    shrink(full, 512).convert('RGB').save(os.path.join(STORE, 'icon_512.png'))
    print('Đã ghi', OUT, 'và', STORE)


if __name__ == '__main__':
    main()
