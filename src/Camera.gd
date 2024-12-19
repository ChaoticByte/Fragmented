extends Camera2D

var drag = false

@onready var user_interface_container = %UserInterfaceContainer
@onready var image_viewport = %ImageViewport
@onready var image_viewport_display = %ImageViewportDisplay

func _input(event):
	if event.is_action_pressed("zoom_out") && !Globals.camera_freeze:
		zoom_out()
	elif event.is_action_pressed("zoom_in") && !Globals.camera_freeze:
		zoom_in()
	if event.is_action_pressed("drag") && !Globals.camera_freeze:
		drag = true
	elif event.is_action_released("drag"):
		drag = false
	if drag && event is InputEventMouseMotion:
		global_position -= event.relative / zoom

func fit_image():
	if image_viewport.image_original_tex != null:
		var ui_container_size = user_interface_container.size
		var image_size = image_viewport.image_original_tex.get_size()
		var viewport_size = get_viewport_rect().size
		var zoomf = (viewport_size.x - ui_container_size.x) / image_size.x / 1.1
		if zoomf * image_size.y > viewport_size.y:
			zoomf = viewport_size.y / image_size.y / 1.1
		zoom = Vector2(zoomf, zoomf)
		global_position = Vector2(-((ui_container_size.x) / 2 / zoom.x), 0)

func zoom_in():
	var old_mouse_pos = get_global_mouse_position()
	zoom *= 1.2
	global_position += old_mouse_pos - get_global_mouse_position()
	image_viewport_display.update_zoom_texture_filter(zoom)

func zoom_out():
	var old_mouse_pos = get_global_mouse_position()
	zoom *= 1/1.2
	global_position += old_mouse_pos - get_global_mouse_position()
	image_viewport_display.update_zoom_texture_filter(zoom)

func _on_fit_image_button_pressed():
	fit_image()
