extends Node

var _load_regex: RegEx = RegEx.create_from_string(r'\/\/!load\s(.*)')
var _load_additional_regex: RegEx = RegEx.create_from_string(r'\/\/!load\+\s(\w*)\s(.*)')
var _iterate_regex: RegEx = RegEx.create_from_string(r'\/\/!steps\s([0-9]+)\s*')

func parse_load_directive(shader_code: String) -> PackedStringArray:
	var regex_match = self._load_regex.search(shader_code)
	if regex_match == null:
		return []
	return regex_match.strings

func parse_load_additional_directive(shader_code: String) -> Array[PackedStringArray]:
	var results : Array[PackedStringArray] = []
	for m in self._load_additional_regex.search_all(shader_code):
		results.append(m.strings)
	return results

func parse_steps_directive(shader_code: String) -> int:
	var regex_match = self._iterate_regex.search(shader_code)
	if regex_match == null:
		return 1
	else:
		return max(0, int(regex_match.strings[1]))
