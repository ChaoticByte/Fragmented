shader_type canvas_item;

#include "res://shaderlib/hsv.gdshaderinc"

//!load ./swamp.jpg

void fragment() {
	COLOR = hsv_multiply(hsv_offset(COLOR, -0.3, 0.9, 0.0), 1.0, 0.44, 1.0);
}
