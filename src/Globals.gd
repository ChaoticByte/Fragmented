extends Node

var camera_freeze = false
@onready var shader: Shader = ShaderPresets.presets[ShaderPresets.default_preset]
var target_viewport: SubViewport
