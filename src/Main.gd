extends Node

@onready var editor_window = %EditorWindow
@onready var ui_container = %UserInterfaceContainer
@onready var app_name = ProjectSettings.get_setting("application/config/name")

func _ready():
	update_title()
	# position windows
	get_window().position = Vector2i(
		editor_window.position.x + editor_window.size.x + 50,
		editor_window.position.y)
	get_window().min_size = Vector2i(400, 400)
	editor_window.min_size = Vector2i(560, 400)
	# Load last opened file
	Filesystem.remember_last_opened_file()
	if Filesystem.last_shader_savepath != "":
		ui_container.get_node("Editor")._on_open_shader_dialog_file_selected(Filesystem.last_shader_savepath)

func update_title(current_file: String = ""):
	if current_file == "":
		get_window().title = app_name + " - Viewer"
		editor_window.title = app_name + " - Editor"
	else:
		get_window().title = current_file + " - " + app_name + " - Viewer"
		editor_window.title = current_file + " - " + app_name + " - Editor"
