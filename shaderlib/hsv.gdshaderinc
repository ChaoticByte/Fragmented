
// rgb2hsv and hsv2rgb functions adapted from https://godotshaders.com/shader/hsv-adjustment/

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

// Offset the hue, saturation and brightness of a RGB color
vec4 hsv_offset(
	vec4 rgba,
	float offset_hue,
	float offset_saturation,
	float offset_brightness
) {
	vec4 c = rgb2hsv(rgba);
	c.x += offset_hue;
	c.y += offset_saturation;
	c.z += offset_brightness;
	return hsv2rgb(c);
}

// Multiply the hue, saturation and brightness of a RGB color
vec4 hsv_multiply(
	vec4 rgba,
	float mult_hue,
	float mult_saturation,
	float mult_brightness
) {
	vec4 c = rgb2hsv(rgba);
	c.x *= mult_hue;
	c.y *= mult_saturation;
	c.z *= mult_brightness;
	return hsv2rgb(c);
}
