import os
from PIL import Image, ImageDraw

def create_template(w, h, filename):
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    corner_color = (255, 50, 50, 180)
    edge_color = (50, 255, 50, 180)
    center_color = (50, 50, 255, 180)
    grid_color = (255, 255, 255, 128)
    margin = 8
    
    # Draw background areas
    for y in range(h):
        for x in range(w):
            is_left = x < margin
            is_right = x >= w - margin
            is_top = y < margin
            is_bottom = y >= h - margin
            
            if (is_left and is_top) or (is_left and is_bottom) or (is_right and is_top) or (is_right and is_bottom):
                img.putpixel((x, y), corner_color)
            elif is_left or is_right or is_top or is_bottom:
                img.putpixel((x, y), edge_color)
            else:
                img.putpixel((x, y), center_color)
                
    # Draw grid lines
    for x in range(w):
        if x == margin or x == w - margin:
            draw.line([(x, 0), (x, h)], fill=grid_color)
    for y in range(h):
        if y == margin or y == h - margin:
            draw.line([(0, y), (w, y)], fill=grid_color)
            
    img.save(filename)

os.makedirs('assets/sprites/ui/_templates', exist_ok=True)
create_template(64, 64, 'assets/sprites/ui/_templates/panel_template_64x64.png')
create_template(64, 32, 'assets/sprites/ui/_templates/button_template_64x32.png')
print("Templates generated.")
