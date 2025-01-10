shader_type canvas_item;

//!steps 9
//!load ./images/swamp.jpg

const float strength = 0.01;

void fragment() {
	float v;
	if (STEP % 3 == 0) {
		v = COLOR.r; // 3 times
	} else if (STEP % 3 == 0) {
		v = COLOR.g; // 3 times
	} else {
		v = COLOR.b; // 3 times
	}
	vec2 uv = UV;
	uv.y -= v * strength;
	COLOR = texture(TEXTURE, uv);
}
