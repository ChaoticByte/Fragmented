extends Node

@onready var editor_window = %EditorWindow

func _ready():
	# position windows
	get_window().position = Vector2i(
		editor_window.position.x + editor_window.size.x + 50,
		editor_window.position.y)
	get_window().title = ProjectSettings.get_setting("application/config/name") + " - Viewer"
	get_window().min_size = Vector2i(400, 400)
	editor_window.title = ProjectSettings.get_setting("application/config/name") + " - Editor"
	editor_window.min_size = Vector2i(560, 400)
