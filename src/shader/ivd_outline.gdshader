shader_type canvas_item;

uniform vec2 zoom_level = vec2(1.0);
const float thickness = 3.0;

void fragment() {
	vec2 t = thickness * TEXTURE_PIXEL_SIZE / zoom_level;
	if (
		UV.x < t.x ||
		UV.y < t.y ||
		UV.x > 1.0-t.x ||
		UV.y > 1.0-t.y
	) {
		COLOR = mix(COLOR, vec4(1.0), 0.5);
	}
}
