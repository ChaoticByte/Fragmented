
/*
	Edge Detection (Sobel Filter and Gaussian Blur) by FencerDevLog, adapted
	original code: https://godotshaders.com/shader/edge-detection-sobel-filter-and-gaussian-blur/
	license of the original code: CC0
*/

vec3 _convolution(sampler2D tex, vec2 uv, vec2 pixel_size) {
	vec3 conv = vec3(0.0);
	// Gaussian blur kernel
	float gauss[25] = {
		0.00390625, 0.015625, 0.0234375, 0.015625, 0.00390625,
		0.015625, 0.0625, 0.09375, 0.0625, 0.015625,
		0.0234375, 0.09375, 0.140625, 0.09375, 0.0234375,
		0.015625, 0.0625, 0.09375, 0.0625, 0.015625,
		0.00390625, 0.015625, 0.0234375, 0.015625, 0.00390625
	};
	for (int row = 0; row < 5; row++) {
		for (int col = 0; col < 5; col++) {
			conv += texture(tex, uv + vec2(float(col - 2), float(row - 2)) * pixel_size).rgb * gauss[row * 5 + col];
		}
	}
	return conv;
}

vec4 sobel(sampler2D tex, vec2 uv) {
	vec2 pixel_size = 1.0/vec2(textureSize(tex, 0));
	vec3 pixels[9];  // Sobel kernel
	// [0, 1, 2]
	// [3, 4, 5]
	// [6, 7, 8]
	for (int row = 0; row < 3; row++) {
		for (int col = 0; col < 3; col++) {
			vec2 uv_ = uv + vec2(float(col - 1), float(row - 1)) * pixel_size;
			pixels[row * 3 + col] = _convolution(tex, uv_, pixel_size);
		}
	}

	// Sobel operator
	vec3 gx = (
		pixels[0] * -1.0 + pixels[3] * -2.0 + pixels[6] * -1.0
		+ pixels[2] * 1.0 + pixels[5] * 2.0 + pixels[8] * 1.0
	);
	vec3 gy = (
		pixels[0] * -1.0 + pixels[1] * -2.0 + pixels[2] * -1.0
		+ pixels[6] * 1.0 + pixels[7] * 2.0 + pixels[8] * 1.0
	);
	vec3 sobel = sqrt(gx * gx + gy * gy);
	return vec4(sobel, 1.0);
}