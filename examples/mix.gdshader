shader_type canvas_item;

//!load ./swamp.jpg

//!load+ img2 ./overlay.jpg
uniform sampler2D img2: repeat_enable, filter_nearest;

void fragment() {
	COLOR = mix(COLOR, texture(img2, UV), .2);
}
