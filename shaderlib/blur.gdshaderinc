
/*
	gaussian_blur adapted from https://godotshaders.com/shader/customizable-gausian-blur/
	original code by https://godotshaders.com/author/djbob-gaming-yt/
	maximum radius is 64
*/
vec4 gaussian_blur(sampler2D texture, vec2 uv, int radius, float sigma) {
	vec2 resolution = 1.0 / vec2(textureSize(texture, 0));
	// calculate kernel
	float kernel[64];
	float sum = 0.0;
	for (int i = 0; i <= radius; i++) {
		kernel[i] = exp(-0.5 * float(i * i) / (sigma * sigma));
		sum += i == 0 ? kernel[i] : 2.0 * kernel[i];
	}
	for (int i = 0; i <= radius; i++) {
		kernel[i] /= sum;
	}
	//
	vec4 final_color = vec4(0.0);
	float total_weight = 0.0;
	for (int x = -radius; x <= radius; x++) {
		for (int y = -radius; y <= radius; y++) {
			float weight = kernel[abs(x)] * kernel[abs(y)];
			vec2 offset = vec2(float(x), float(y)) * resolution;
			final_color += texture(texture, uv + offset) * weight;
			total_weight += weight;
		}
	}
	final_color /= total_weight;
	return final_color;
}
