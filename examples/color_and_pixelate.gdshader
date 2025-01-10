shader_type canvas_item;

#include "res://shaderlib/colorspaces.gdshaderinc"
#include "res://shaderlib/effects.gdshaderinc"

//!load ./images/swamp.jpg

void fragment() {
	COLOR = pixelate(TEXTURE, UV, 200.0);
	vec4 hsv = rgb2hsv(COLOR);
	hsv.xyz += vec3(0.65, .42-(hsv.y*.3), -.125);
	hsv.xyz *= vec3(1.0, 1.0, 1.25);
	COLOR = hsv2rgb(hsv);
}
