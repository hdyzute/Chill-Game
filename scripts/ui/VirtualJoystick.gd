extends Control
class_name CustomJoystick

signal joystick_moved(direction: Vector2)

@export var max_distance: float = 50.0

var is_dragging: bool = false
var center_pos: Vector2
var current_pos: Vector2

var base_rect: Panel
var knob_rect: Panel
var touch_index: int = -1

func _ready() -> void:
	# Mở rộng toàn màn hình để bắt touch ở bất kỳ đâu
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE # Không cản trở nút bấm UI
	
	base_rect = Panel.new()
	var base_sb = StyleBoxFlat.new()
	base_sb.bg_color = Color(0, 0, 0, 0.3)
	base_sb.corner_radius_top_left = 100
	base_sb.corner_radius_top_right = 100
	base_sb.corner_radius_bottom_right = 100
	base_sb.corner_radius_bottom_left = 100
	base_rect.add_theme_stylebox_override("panel", base_sb)
	base_rect.size = Vector2(max_distance*2, max_distance*2)
	base_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(base_rect)
	
	knob_rect = Panel.new()
	var knob_sb = StyleBoxFlat.new()
	knob_sb.bg_color = Color(1, 1, 1, 0.5)
	knob_sb.corner_radius_top_left = 100
	knob_sb.corner_radius_top_right = 100
	knob_sb.corner_radius_bottom_right = 100
	knob_sb.corner_radius_bottom_left = 100
	knob_rect.add_theme_stylebox_override("panel", knob_sb)
	knob_rect.size = Vector2(max_distance, max_distance)
	knob_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(knob_rect)
	
	base_rect.hide()
	knob_rect.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			touch_index = event.index
			is_dragging = true
			center_pos = event.position
			current_pos = event.position
			base_rect.show()
			knob_rect.show()
			_update_ui()
		elif not event.pressed and event.index == touch_index:
			is_dragging = false
			touch_index = -1
			base_rect.hide()
			knob_rect.hide()
			joystick_moved.emit(Vector2.ZERO)
			
	elif event is InputEventScreenDrag and is_dragging and event.index == touch_index:
		current_pos = event.position
		_clamp_and_emit()
		
	# Giữ hỗ trợ chuột cho PC test
	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and touch_index == -1:
			touch_index = 99
			is_dragging = true
			center_pos = event.position
			current_pos = event.position
			base_rect.show()
			knob_rect.show()
			_update_ui()
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT and touch_index == 99:
			is_dragging = false
			touch_index = -1
			base_rect.hide()
			knob_rect.hide()
			joystick_moved.emit(Vector2.ZERO)
			
	elif event is InputEventMouseMotion and is_dragging and touch_index == 99:
		current_pos = event.position
		_clamp_and_emit()

func _clamp_and_emit() -> void:
	var diff = current_pos - center_pos
	if diff.length() > max_distance:
		diff = diff.normalized() * max_distance
		current_pos = center_pos + diff
		
	var dir = diff / max_distance
	joystick_moved.emit(dir)
	_update_ui()

func _update_ui() -> void:
	if base_rect and knob_rect and is_dragging:
		base_rect.position = center_pos - base_rect.size / 2.0
		knob_rect.position = current_pos - knob_rect.size / 2.0


