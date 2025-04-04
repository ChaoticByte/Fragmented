extends Camera2D

@onready var image_viewport_display = %ImageViewportDisplay

var drag = false

func _input(event):
	if event.is_action_pressed("zoom_out"):
		zoom_out()
	elif event.is_action_pressed("zoom_in"):
		zoom_in()
	if event.is_action_pressed("drag"):
		self.drag = true
	elif event.is_action_released("drag"):
		self.drag = false
	if self.drag && event is InputEventMouseMotion:
		self.global_position -= event.relative / self.zoom

var old_zoom = self.zoom

func _process(_delta: float) -> void:
	if self.zoom != old_zoom:
		image_viewport_display.update_zoom_texture_filter(self.zoom)
		image_viewport_display.material.set_shader_parameter("zoom_level", self.zoom)
		old_zoom = self.zoom

func fit_image():
	if Filesystem.original_image != null:
		var image_size = Filesystem.original_image.get_size()
		var viewport_size = get_viewport_rect().size
		var zoomf = 1.0
		if viewport_size.x / image_size.x * image_size.y > viewport_size.y:
			zoomf = viewport_size.y / image_size.y / 1.25
		else:
			zoomf = viewport_size.x / image_size.x / 1.2 
		self.zoom = Vector2(zoomf, zoomf)
		self.global_position = Vector2(0, 0)

func zoom_in():
	var old_mouse_pos = get_global_mouse_position()
	self.zoom *= 1.2
	self.global_position += old_mouse_pos - get_global_mouse_position()

func zoom_out():
	var old_mouse_pos = get_global_mouse_position()
	self.zoom *= 1/1.2
	self.global_position += old_mouse_pos - get_global_mouse_position()

func _on_fit_image_button_pressed():
	fit_image()
