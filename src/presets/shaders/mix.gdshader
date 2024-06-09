shader_type canvas_item;

//!load img2 ./icon.png
uniform sampler2D img2: repeat_enable, filter_nearest;

void fragment() {
	COLOR = mix(COLOR, texture(img2, UV), .5);
}
