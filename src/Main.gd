extends Node2D

@onready var camera = $Camera
@onready var image_viewport = $ImageViewport
@onready var image_sprite = $ImageViewport/ImageSprite
@onready var ui_container = $UI_Layer/UserInterfaceContainer
@onready var ui_control_fileopen = $UI_Layer/UserInterfaceContainer/OpenFileDialog
@onready var ui_control_filesave = $UI_Layer/UserInterfaceContainer/SaveFileDialog

func _ready():
	GlitchShader.target_sprite = image_sprite
	GlitchShader.shader = ShaderPresets.presets[ShaderPresets.default_preset]

func _on_open_image_button_pressed():
	if OS.get_name() == "Android":
		Engine.get_singleton("GodotGetImage").getGalleryImage()
	else:
		ui_control_fileopen.show()

func _on_open_file_dialog_file_selected(path):
	var img = Image.new()
	var err = img.load(path)
	if err == OK:
		image_viewport.set_original_image(img)
		GlitchShader.apply()
		camera.fit_image()
	else:
		print("An error occured!")

func _on_save_image_button_pressed():
	ui_control_filesave.show()

func _on_save_file_dialog_file_selected(path):
	# Get viewport texture
	await RenderingServer.frame_post_draw # for good measure
	var img = image_viewport.get_texture().get_image()
	var err = img.save_png(path)
	if err != OK:
		print("An error occured!")
