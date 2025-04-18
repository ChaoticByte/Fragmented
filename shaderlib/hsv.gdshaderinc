
/*
	rgb2hsv and hsv2rgb functions adapted
	from https://godotshaders.com/shader/hsv-adjustment/
	original code by https://godotshaders.com/author/al1-ce/

	Color space conversion functions always work with vec4.
	The fourth value is always alpha.
*/

// Convert RGB to HSV (hue, saturation, brightness)
vec4 rgb2hsv(vec4 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec4(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x, c.a);
}

// Convert HSV back to RGB (red, green, blue)
vec4 hsv2rgb(vec4 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	vec3 rgb =  c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
	return vec4(rgb.r, rgb.g, rgb.b, c.a);
}
