extends Node

var _load_regex: RegEx
var _load_additional_regex: RegEx

func _ready():
	self._load_regex = RegEx.new()
	self._load_additional_regex = RegEx.new()
	self._load_regex.compile(r'\/\/!load\s(.*)')
	self._load_additional_regex.compile(r'\/\/!load\+\s(\w*)\s(.*)')

func parse_load_directive(shader: Shader) -> PackedStringArray:
	var regex_match = self._load_regex.search(Filesystem.shader.code)
	if regex_match == null: # Error!
		printerr("Didn't find any load directives!")
		return []
	return regex_match.strings

func parse_load_additional_directive(shader: Shader) -> Array[PackedStringArray]:
	var results : Array[PackedStringArray] = []
	for m in self._load_additional_regex.search_all(shader.code):
		results.append(m.strings)
	return results
