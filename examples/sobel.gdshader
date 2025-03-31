shader_type canvas_item;

//!load ./images/noisy.png

#include "./shaderlib/sobel.gdshaderinc"

void fragment() {
	// Sobel Filter
	COLOR = sobel(TEXTURE, UV);
}
