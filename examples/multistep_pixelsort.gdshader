shader_type canvas_item;

#include "./shaderlib/pixelsort.gdshaderinc"

//!steps 1500
uniform int STEP;

//!load ./images/mountain.jpg

void fragment() {
	// pixel sorting works in multiple steps
	COLOR = pixelsort_step(
		TEXTURE, UV,
		DIRECTION_BOTTOM_TO_TOP,
		COLOR_MODE_OKLCH,
		{true, false, false},
		{-INF, .007, -INF},
		{INF, INF, INF},
		STEP);
}
