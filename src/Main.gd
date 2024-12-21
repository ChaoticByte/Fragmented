extends Node

@onready var editor_window = %EditorWindow

func _ready():
	# position windows
	get_window().position = Vector2i(
		editor_window.position.x + editor_window.size.x + 50,
		editor_window.position.y)
	get_window().title = ProjectSettings.get_setting("application/config/name") + " - Viewer"
	editor_window.title = ProjectSettings.get_setting("application/config/name") + " - Editor"
