extends Node

var camera_freeze = false
@onready var shader: Shader = load("res://src/shader/template.gdshader")
var target_viewport: SubViewport
var cwd = "."
var last_image_savepath = ""
var last_shader_savepath = ""
