extends Node2D

@onready var image_viewport = %ImageViewport
@onready var ui_control_filesave = %SaveImageDialog


func _ready():
	Globals.target_viewport = image_viewport

func _on_save_image_button_pressed():
	if image_viewport.get_result() != null:
		ui_control_filesave.current_path = Globals.last_image_savepath
		ui_control_filesave.show()

func _on_save_image_dialog_file_selected(path):
	print("Export ", path)
	var err = image_viewport.get_result().save_png(path)
	if err != OK:
		print("An error occured!")
	else:
		Globals.last_image_savepath = path
