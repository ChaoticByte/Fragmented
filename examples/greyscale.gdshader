shader_type canvas_item;

//!load ./images/swamp.jpg

void fragment() {
	float b = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
	COLOR.r = b;
	COLOR.g = b;
	COLOR.b = b;
}
