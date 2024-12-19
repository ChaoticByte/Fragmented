shader_type canvas_item;

//!load ./swamp.jpg

const float strength = 0.1;

void fragment() {
	vec2 uv = UV;
	float b = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
	uv.x = mix(uv.x, b, strength);
	uv.y = mix(uv.y, b, strength);
	COLOR = texture(TEXTURE, uv);
}
