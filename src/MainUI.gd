extends Control

@onready var open_shader_dialog = %OpenShaderDialog
@onready var save_image_dialog = %SaveImageDialog

@onready var open_shader_button = %OpenShaderButton
@onready var save_image_button = %SaveImageButton
@onready var fit_image_button = %FitImageButton
@onready var apply_shader_button = %ApplyShaderButton

@onready var status_indicator = %StatusIndicator
@onready var error_msg_dialog = %ErrorMessageDialog

@onready var main = get_tree().root.get_node("Main")
@onready var compositor = %Compositor
@onready var camera = %Camera

var status_okay_texture: CompressedTexture2D = preload("uid://m1omb6g45vst")
var status_error_texture: CompressedTexture2D = preload("uid://04iv1gogpuhu")

enum Status {OKAY, ERROR, UNKNOWN = -1}

#

func _input(event):
	if event.is_action_pressed("apply_shader"):
		_on_apply_shader_button_pressed()
	elif event.is_action_pressed("save_shader"):
		accept_event() # Event is now handled.

#

func set_buttons_disabled(disabled: bool):
	for b in [open_shader_button, save_image_button, fit_image_button, apply_shader_button, status_indicator]:
		b.disabled = disabled

func _on_open_shader_button_pressed():
	set_buttons_disabled(true)
	open_shader_dialog.show()

func _on_fit_image_button_pressed():
	camera.fit_image()

func _on_apply_shader_button_pressed():
	set_buttons_disabled(true)
	var errors = await compositor.update()
	set_buttons_disabled(false)
	if len(errors) > 0:
		update_status(Status.ERROR, "\n".join(errors))
	else:
		update_status(Status.OKAY)
		status_indicator.disabled = true

func _on_save_image_button_pressed():
	if Filesystem.result != null:
		set_buttons_disabled(true)
		save_image_dialog.current_path = Filesystem.last_image_savepath
		save_image_dialog.show()

#

func _on_open_shader_dialog_file_selected(path: String):
	Filesystem.shader_path = path
	main.update_title(path.split("/")[-1])
	self._on_apply_shader_button_pressed()

func _on_open_shader_dialog_canceled() -> void:
	set_buttons_disabled(false)

func _on_open_shader_dialog_confirmed() -> void:
	set_buttons_disabled(false)

func _on_save_image_dialog_file_selected(path):
	Filesystem.save_result(path)
	set_buttons_disabled(false)

func _on_save_image_dialog_canceled() -> void:
	set_buttons_disabled(false)

func _on_save_image_dialog_confirmed() -> void:
	set_buttons_disabled(false)

#

func update_status(status: Status, msg: String = ""):
	error_msg_dialog.dialog_text = msg
	error_msg_dialog.reset_size()
	if status == Status.OKAY:
		status_indicator.texture_normal = status_okay_texture
	elif status == Status.ERROR:
		status_indicator.texture_normal = status_error_texture
	else:
		status_indicator.texture_normal = null
	if msg == "":
		status_indicator.disabled = true
	else:
		status_indicator.disabled = false

func _on_status_indicator_pressed() -> void:
	error_msg_dialog.show()
