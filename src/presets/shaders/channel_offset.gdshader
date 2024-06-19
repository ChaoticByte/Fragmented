shader_type canvas_item;

const vec2 offset_r = vec2(-0.002, -0.002);
const vec2 offset_g = vec2(0., 0.);
const vec2 offset_b = vec2(0.002, 0.002);

void fragment() {
	COLOR.r = texture(TEXTURE , UV + offset_r).r;
	COLOR.g = texture(TEXTURE , UV + offset_g).g;
	COLOR.b = texture(TEXTURE , UV + offset_b).b;
	COLOR.a = COLOR.a;
}
