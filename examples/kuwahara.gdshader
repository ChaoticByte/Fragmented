shader_type canvas_item;

//!load ./images/mountain.jpg

#include "res://shaderlib/kuwahara.gdshaderinc"
#include "res://shaderlib/hsv.gdshaderinc"

void fragment() {
	// Kuwahara
	COLOR.rgb = kuwahara(TEXTURE, UV, 20, 80.0, 18.0, 0.6, .15, 8);
	// A litte bit of color adjustments
	vec4 hsv = rgb2hsv(COLOR);
	hsv.x += .03;
	hsv.y *= 1.4;
	COLOR = hsv2rgb(hsv);
}
