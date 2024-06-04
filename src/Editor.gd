extends Control

@onready var preset_options = $PresetOptions
@onready var code_editor = $CodeEdit

@onready var camera_freeze = get_parent().get_parent().get_parent().find_child("Camera").freeze
@onready var camera_unfreeze = get_parent().get_parent().get_parent().find_child("Camera").unfreeze

var selected_preset_name = ShaderPresets.default_preset

#

const gdshader_datatypes = [
	"in", "out", "inout",
	"varying", "uniform",
	"const", "lowp", "mediump", "heighp",
	"void",
	"bool", "bvec2", "bvec3", "bvec4",
	"int", "ivec2", "ivec3", "ivec4",
	"uint", "uvec2", "uvec3", "uvec4",
	"float", "vec2", "vec3", "vec4",
	"mat2", "mat3", "mat4",
	"sample2D", "isampler2D", "usample2D",
	"sampler2DArray", "isample2DArray", "usample2DArray",
	"sample3D", "isampler3D", "usample3D",
	"samplerCube", "sampleCubeArray"
]

const gdshader_builtins = [
	"TIME", "PI", "TAU", "E",
	"MODEL_MATRIX",
	"CANVAS_MATRIX",
	"SCREEN_MATRIX",
	"INSTANCE_ID",
	"INSTANCE_CUSTOM",
	"AT_LIGHT_PASS",
	"TEXTURE_PIXEL_SIZE",
	"VERTEX",
	"VERTEX_ID",
	"UV",
	"COLOR",
	"POINT_SIZE",
	"FRAGCOORD",
	"SCREEN_PIXEL_SIZE",
	"POINT_COORD",
	"TEXTURE",
	"TEXTURE_PIXEL_SIZE",
	"SPECULAR_SHININESS_TEXTURE",
	"SPECULAR_SHININESS",
	"UV",
	"SCREEN_UV",
	"SCREEN_TEXTURE",
	"NORMAL",
	"NORMAL_TEXTURE",
	"NORMAL_MAP",
	"NORMAL_MAP_DEPTH",
	"SHADOW_VERTEX",
	"LIGHT_VERTEX"
]

const gdshader_flow_control = [
	"if", "else",
	"for",
	"do", "while",
	"switch", "case",
	"break",
	"return"
]

class ShaderSyntaxHighlighter extends CodeHighlighter:
	func _init():
		add_color_region("//", "", Color.WEB_GRAY, true)
		add_color_region("/*", "*/", Color.WEB_GRAY, false)
		function_color = Color.INDIAN_RED
		keyword_colors = {
			"shader_type": Color.ORCHID
		}
		for dt in gdshader_datatypes:
			keyword_colors[dt] = Color.INDIAN_RED
		for bi in gdshader_builtins:
			keyword_colors[bi] = Color.DARK_TURQUOISE
		for fc in gdshader_flow_control:
			keyword_colors[fc] = Color.CORAL
		member_variable_color = Color.LIGHT_BLUE
		number_color = Color.AQUA
		symbol_color = Color.GRAY

func _on_code_edit_code_completion_requested():
	for dt in gdshader_datatypes:
		code_editor.code_completion_prefixes.append(dt)
		code_editor.add_code_completion_option(CodeEdit.KIND_CLASS, dt, dt, Color.INDIAN_RED)
	for bi in gdshader_builtins:
		code_editor.code_completion_prefixes.append(bi)
		code_editor.add_code_completion_option(CodeEdit.KIND_VARIABLE, bi, bi, Color.DARK_TURQUOISE)
	for fc in gdshader_flow_control:
		code_editor.code_completion_prefixes.append(fc)
		code_editor.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, fc, fc, Color.DARK_TURQUOISE)
	code_editor.update_code_completion_options(true)

#

func _ready():
	code_editor.code_completion_enabled = true
	code_editor.syntax_highlighter = ShaderSyntaxHighlighter.new()
	for c in get_children():
		c.connect("mouse_entered", camera_freeze)
		c.connect("mouse_exited", camera_unfreeze)
	update()

func _on_code_edit_text_changed():
	var shader = Shader.new()
	shader.code = code_editor.text
	GlitchShader.shader = shader
	GlitchShader.apply()

func _on_preset_options_item_selected(index):
	selected_preset_name = preset_options.get_item_text(index)
	GlitchShader.shader = ShaderPresets.presets[selected_preset_name]
	GlitchShader.apply()
	update()

func update():
	preset_options.clear()
	# the following lines are weird af
	var presets: Array[String] = []
	var current_p_idx = 0
	for p in ShaderPresets.presets:
		presets.append(p)
		if p == selected_preset_name:
			current_p_idx = len(presets) - 1
		preset_options.add_item(p)
	preset_options.select(current_p_idx)
	# weirdness ends here
	code_editor.text = GlitchShader.shader.code
