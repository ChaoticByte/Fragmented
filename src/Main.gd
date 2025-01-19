extends Node

@onready var editor_window = %EditorWindow
@onready var ui_container = %UserInterfaceContainer
@onready var app_name = ProjectSettings.get_setting("application/config/name")

func show_help():
	print(
		"Usage:\n\n",
		"./Fragmented cmd --shader PATH [--load-image PATH]\n\n",
		"  --shader PATH      The path to the shader\n",
		"  --output PATH      Where to write the resulting image to\n",
		"  --load-image PATH  The path to the image. This will overwrite the\n",
		"                     load directive of the shader file (optional)\n")

func parse_custom_cmdline(args: PackedStringArray):
	var kwargs: Dictionary = {"--shader": null, "--output": null, "--load-image": null}
	var args_len = args.size()
	var i = 0
	while i < args_len:
		var a = args[i]
		if a in kwargs && args_len > i+1:
			i += 1
			kwargs[a] = args[i]
		i += 1
	return kwargs

func _ready():
	var args = OS.get_cmdline_args()
	if "cmd" in args: # commandline interface
		if "help" in args:
			show_help()
			get_tree().quit(1)
		else:
			var kwargs: Dictionary = parse_custom_cmdline(args)
			if kwargs["--shader"] == null or kwargs["--output"] == null:
				show_help()
				get_tree().quit(1)
			else:
				Filesystem.load_shader(kwargs["--shader"])
				var errors = []
				if kwargs["--load-image"] == null:
					errors = await $Compositor.update()
				else:
					errors = await $Compositor.update(kwargs["--load-image"])
				if errors.size() > 0:
					print("One or more errors occurred.")
					for e in errors:
						printerr(e)
					get_tree().quit(1)
				else:
					Filesystem.save_result(kwargs["--output"])
					get_tree().quit(0)
	else:
		update_title()
		# position windows
		get_window().position = Vector2i(
			editor_window.position.x + editor_window.size.x + 50,
			editor_window.position.y)
		get_window().min_size = Vector2i(400, 400)
		editor_window.min_size = Vector2i(560, 400)
		editor_window.show()
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
