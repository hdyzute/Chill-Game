extends SceneTree

func _init():
	var dir = DirAccess.open("res://assets/sprites/ui")
	if not dir.dir_exists("_templates"):
		dir.make_dir("_templates")
		
	_create_template(64, 64, "panel_template_64x64.png")
	_create_template(64, 32, "button_template_64x32.png")
	print("Templates generated.")
	quit()

func _create_template(w: int, h: int, filename: String):
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	var corner_color = Color(1.0, 0.2, 0.2, 0.7) # Red corners
	var edge_color = Color(0.2, 1.0, 0.2, 0.7) # Green edges
	var center_color = Color(0.2, 0.2, 1.0, 0.7) # Blue center
	var margin = 8
	
	for y in range(h):
		for x in range(w):
			var is_left = x < margin
			var is_right = x >= w - margin
			var is_top = y < margin
			var is_bottom = y >= h - margin
			
			if (is_left and is_top) or (is_left and is_bottom) or (is_right and is_top) or (is_right and is_bottom):
				img.set_pixel(x, y, corner_color)
			elif is_left or is_right or is_top or is_bottom:
				img.set_pixel(x, y, edge_color)
			else:
				img.set_pixel(x, y, center_color)
				
	# Grid overlay
	var dark = Color(1, 1, 1, 0.5)
	for x in range(w):
		if x == margin or x == w - margin:
			for y in range(h): img.set_pixel(x, y, dark)
	for y in range(h):
		if y == margin or y == h - margin:
			for x in range(w): img.set_pixel(x, y, dark)
				
	img.save_png("res://assets/sprites/ui/_templates/" + filename)
