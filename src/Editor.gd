extends Control

@onready var code_editor = %CodeEdit

@onready var open_shader_dialog = %OpenShaderDialog
@onready var save_shader_dialog = %SaveShaderDialog
@onready var ui_control_filesave = %SaveImageDialog

@onready var save_image_button = %SaveImageButton

@onready var status_indicator = %StatusIndicator
@onready var error_msg_dialog = %ErrorMessageDialog

@onready var main = get_tree().root.get_node("Main")
@onready var compositor = main.get_node("%Compositor")
@onready var camera = main.get_node("%Camera")

#

var status_okay_texture: CompressedTexture2D = preload("uid://m1omb6g45vst")
var status_error_texture: CompressedTexture2D = preload("uid://04iv1gogpuhu")

# # # # # # # # # # #
# GDShader keywords #
# https://github.com/godotengine/godot/blob/e96ad5af98547df71b50c4c4695ac348638113e0/servers/rendering/shader_language.cpp
# https://github.com/godotengine/godot/blob/e96ad5af98547df71b50c4c4695ac348638113e0/servers/rendering/shader_types.cpp
#
const gdshader_boolean_values = [
	"true", "false"
]
const gdshader_datatypes = [
	"void",
	"bool", "bvec2", "bvec3", "bvec4",
	"int", "ivec2", "ivec3", "ivec4",
	"uint", "uvec2", "uvec3", "uvec4",
	"float", "vec2", "vec3", "vec4",
	"mat2", "mat3", "mat4",
	"sampler2D", "isampler2D", "usampler2D",
	"sampler2DArray", "isampler2DArray", "usampler2DArray",
]
const gdshader_precision_modifiers = [
	"lowp", "mediump", "heighp"
]
const gdshader_global_space_keywords = [
	"uniform", "group_uniforms", "varying", "const",
	"struct", "shader_type", "render_mode"
]
const gdshader_uniform_qualifiers = [
	"instance", "global"
]
const gdshader_block_keywords = [
	"if", "else",
	"for", "while", "do",
	"switch", "case",
	"default", "break", "continue",
	"return", "discard"
]
const gdshader_function_specifier_keywords = [
	"in", "out", "inout"
]
const gdshader_hints = [
	"source_color", "hint_range", "instance_index"
]
const gdshader_sampler_hints = [
	"hint_normal",
	"hint_default_white", "hint_default_black", "hint_default_transparent",
	"hint_anisotropy",
	"hint_roughness_r", "hint_roughness_g", "hint_roughness_b", "hint_roughness_a",
	"hint_roughness_normal", "hint_roughness_gray",
	"hint_screen_texture", "hint_normal_roughness_texture",
	"hint_depth_texture",
	"filter_nearest", "filter_linear",
	"filter_nearest_mipmap", "filter_linear_mipmap",
	"filter_nearest_mipmap_anisotropic", "filter_linear_mipmap_anisotropic",
	"repeat_enable", "repeat_disable"
]
const gdshader_builtin_functions = [
	"radians", "degrees",
	"sin", "cos", "tan", "asin", "acos", "atan", "sinh", "cosh", "tanh",
	"asinh", "acosh", "atanh",
	"pow", "exp", "exp2", "log", "log2", "sqrt", "inversesqrt",
	"abs", "sign", "floor", "trunc", "round", "roundEven", "ceil", "fract",
	"mod", "modf", "min", "max", "clamp",
	"mix", "step", "smoothstep",
	"isnan", "isinf",
	"floatBitsToInt", "floatBitsToUint", "intBitsToFloat", "uintBitsToFloat",
	"length", "distance",
	"dot", "cross",
	"normalize", "reflect", "refract", "faceforward",
	"matrixCompMult", "outerProduct", "transpose",
	"determinant", "inverse",
	"lessThan", "greaterThan", "lessThanEqual", "greaterThanEqual",
	"equal", "notEqual",
	"any", "all", "not",
	"textureSize", "texture", "textureProj", "textureLod", "texelFetch",
	"textureProjLod", "textureGrad", "textureProjGrad", "textureGather",
	"textureQueryLod", "textureQueryLevels",
	"dFdx", "dFdxCoarse", "dFdxFine", "dFdy", "dFdyCoarse", "dFdyFine",
	"fwidth", "fwidthCoarse", "fwidthFine"
]
const gdshader_sub_functions = [
	"length", "fma",
	"packHalf2x16", "packUnorm2x16", "packSnorm2x16", "packUnorm4x8", "packSnorm4x8",
	"unpackHalf2x16", "unpackUnorm2x16", "unpackSnorm2x16", "unpackUnorm4x8", "unpackSnorm4x8",
	"bitfieldExtract", "bitfieldInsert", "bitfieldReverse", "bitCount",
	"findLSB", "findMSB",
	"umulExtended", "imulExtended",
	"uaddCarry", "usubBorrow",
	"ldexp", "frexp"
]
const gdshader_builtins = [
	"TIME", "PI", "TAU", "E",
	"VERTEX",
	"UV",
	"COLOR",
	"POINT_SIZE",
	"AT_LIGHT_PASS",
	"TEXTURE_PIXEL_SIZE",
	"SHADOW_VERTEX", "LIGHT_VERTEX",
	"FRAGCOORD",
	"NORMAL", "NORMAL_MAP", "NORMAL_MAP_DEPTH",
	"TEXTURE",
	"POINT_COORD",
	"SPECULAR_SHININESS"
]
# shaderlib
var shaderlib_regex = {
	"hsv": RegEx.create_from_string(r'\s*\#include\s+\"res\:\/\/shaderlib\/hsv\.gdshaderinc\"'),
	"transform": RegEx.create_from_string(r'\s*\#include\s+\"res\:\/\/shaderlib\/transform\.gdshaderinc\"'),
	"transparency": RegEx.create_from_string(r'\s*\#include\s+\"res\:\/\/shaderlib\/transparency\.gdshaderinc\"')
}
const shaderlib_functions = {
	"hsv": ["rgb2hsv", "hsv2rgb", "hsv_offset", "hsv_multiply"],
	"transform": ["place_texture"],
	"transparency": ["alpha_blend"],
}
#
# configure Highlighter
#
class ShaderSyntaxHighlighter extends CodeHighlighter:
	func _init():
		add_color_region("//", "", Color.WEB_GRAY, true)
		add_color_region("/*", "*/", Color.WEB_GRAY, false)
		function_color = Color.INDIAN_RED
		for k in gdshader_boolean_values:
			keyword_colors[k] = Color.INDIAN_RED
		for k in (	gdshader_datatypes
					+ gdshader_hints
					+ gdshader_sampler_hints
					+ gdshader_global_space_keywords
					+ gdshader_function_specifier_keywords
					+ gdshader_precision_modifiers
					+ gdshader_uniform_qualifiers):
			keyword_colors[k] = Color.ORCHID;
		for k in gdshader_block_keywords:
			keyword_colors[k] = Color.CORAL
		for k in gdshader_builtins:
			keyword_colors[k] = Color.DARK_TURQUOISE
		member_variable_color = Color.LIGHT_BLUE
		number_color = Color.AQUA
		symbol_color = Color.GRAY
#
# and code completion
#
func _on_code_edit_code_completion_requested():
	for k in gdshader_boolean_values:
		code_editor.code_completion_prefixes.append(k)
		code_editor.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, k, k, Color.INDIAN_RED)
	for k in (	gdshader_datatypes
				+ gdshader_hints
				+ gdshader_sampler_hints
				+ gdshader_global_space_keywords
				+ gdshader_function_specifier_keywords
				+ gdshader_precision_modifiers
				+ gdshader_uniform_qualifiers):
		code_editor.code_completion_prefixes.append(k)
		code_editor.add_code_completion_option(CodeEdit.KIND_CLASS, k, k, Color.ORCHID)
	for k in gdshader_block_keywords:
		code_editor.code_completion_prefixes.append(k)
		code_editor.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, k, k, Color.CORAL)
	for k in gdshader_builtins:
		code_editor.code_completion_prefixes.append(k)
		code_editor.add_code_completion_option(CodeEdit.KIND_CONSTANT, k, k, Color.DARK_TURQUOISE)
	for k in gdshader_builtin_functions + gdshader_sub_functions:
		code_editor.code_completion_prefixes.append(k)
		code_editor.add_code_completion_option(CodeEdit.KIND_FUNCTION, k, k+"(", Color.INDIAN_RED)
	# shaderlib #
	var shader_code = code_editor.text
	for key in shaderlib_regex:
		if shaderlib_regex[key].search(shader_code) != null:
			if key in shaderlib_functions:
				for k in shaderlib_functions[key]:
					code_editor.code_completion_prefixes.append(k)
					code_editor.add_code_completion_option(CodeEdit.KIND_FUNCTION, k, k+"(", Color.INDIAN_RED)
	# # # # # # #
	code_editor.update_code_completion_options(true)
#
# # # # # # # # # # # #

func _ready():
	code_editor.code_completion_enabled = true
	code_editor.syntax_highlighter = ShaderSyntaxHighlighter.new()
	self.update_code_edit()

func _input(event):
	if event.is_action_pressed("apply_shader"):
		_on_apply_shader_button_pressed()
	elif event.is_action_pressed("save_shader"):
		accept_event() # Event is now handled.
		_on_save_shader_button_pressed()

func update_code_edit():
	code_editor.text = Filesystem.shader_code

enum Status {OKAY, ERROR, UNKNOWN = -1}

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

#

func _on_new_shader_button_pressed():
	main.update_title()
	Filesystem.reset()
	self.update_code_edit()
	compositor.update()
	update_status(Status.UNKNOWN)

func _on_open_shader_button_pressed():
	open_shader_dialog.show()

func _on_save_shader_button_pressed():
	Filesystem.shader_code = code_editor.text
	if Filesystem.last_shader_savepath == "":
		_on_save_shader_as_button_pressed()
	else:
		_on_save_shader_dialog_file_selected(Filesystem.last_shader_savepath)

func _on_save_shader_as_button_pressed() -> void:
	Filesystem.shader_code = code_editor.text
	if Filesystem.last_shader_savepath == "":
		save_shader_dialog.current_file = "filter.gdshader"
	else:
		save_shader_dialog.current_path = Filesystem.last_shader_savepath
	save_shader_dialog.show()

func _on_fit_image_button_pressed():
	camera.fit_image()

func _on_apply_shader_button_pressed():
	save_image_button.disabled = true
	Filesystem.shader_code = code_editor.text
	var errors = await compositor.update()
	if len(errors) > 0:
		update_status(Status.ERROR, "\n".join(errors))
	else:
		update_status(Status.OKAY)
		save_image_button.disabled = false

func _on_save_image_button_pressed():
	if Filesystem.result != null:
		ui_control_filesave.current_path = Filesystem.last_image_savepath
		ui_control_filesave.show()

#

func _on_open_shader_dialog_file_selected(path: String):
	Filesystem.load_shader(path)
	main.update_title(path.split("/")[-1])
	self.update_code_edit()
	self._on_apply_shader_button_pressed()

func _on_save_shader_dialog_file_selected(path):
	Filesystem.save_shader(path)
	main.update_title(path.split("/")[-1])

func _on_save_image_dialog_file_selected(path):
	Filesystem.save_result(path)

#

func _on_status_indicator_pressed() -> void:
	error_msg_dialog.show()
