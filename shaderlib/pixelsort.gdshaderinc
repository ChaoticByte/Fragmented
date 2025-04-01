
/*
	Pixelsorting using odd-even sort

	I roughly followed https://ciphrd.com/2020/04/08/pixel-sorting-on-shader-using-well-crafted-sorting-filters-glsl/
	- vector fields aren't implemented, diagonal sorting is not supported!
*/

#include "./hsv.gdshaderinc"
#include "./oklab.gdshaderinc"

#define INF (1.0/0.0)

#define DIRECTION_LEFT_TO_RIGHT vec2(1, 0)
#define DIRECTION_RIGHT_TO_LEFT vec2(-1, 0)
#define DIRECTION_TOP_TO_BOTTOM vec2(0, 1)
#define DIRECTION_BOTTOM_TO_TOP vec2(0, -1)

#define COLOR_MODE_RGB 0
#define COLOR_MODE_OKLAB 1
#define COLOR_MODE_OKLCH 2
#define COLOR_MODE_HSV 3

vec4 pixelsort_step(
	sampler2D tex, vec2 uv,
	vec2 direction, // e.g. (1, 0) for left-to-right or (0, -1) for bottom-to-top
	                // see DIRECTION_LEFT_TO_RIGHT, etc.
	                // note: vertical sorting doesn't work, so using e.g. (1, 1) won't work
	int color_mode, // 0 = RGB, 1 = OKLAB, 2 = OKLCH, 3 = HSV
	                // see COLOR_MODE_RGB, etc.
	bool color_channel_mask[3], // which color channel(s) to take into account
	float lower_threshold[3],   // lower threshold for pixels to be considered sorted
	                            // when in doubt, use {-INF, -INF, -INF}
	float upper_threshold[3],   // upper threshold; {INF, INF, INF}
	int step_ // from STEP
) {
	// sanitize inputs
	direction = clamp(direction, vec2(-1, -1), vec2(1, 1));
	color_mode = clamp(color_mode, 0, 3);
	// get neighbour
	vec2 texture_size = vec2(textureSize(tex, 0));
	vec2 a = (mod(floor(uv * texture_size), 2.0) * 2.0 - 1.0) * (mod(float(step_), 2.0) * 2.0 - 1.0);
	vec2 neighbour_uv = uv + (direction * a / texture_size);
	//
	vec4 x = texture(tex, uv);
	vec4 y = texture(tex, neighbour_uv);
	if ( // stop at borders
		neighbour_uv.x > 1.0 ||
		neighbour_uv.x < 0.0 ||
		neighbour_uv.y > 1.0 ||
		neighbour_uv.y < 0.0
	) {
		return x;
	} else {
		// convert color if necessary
		// get value to compare
		float vx = 0.0;
		float vy = 0.0;
		vec3 color_x;
		vec3 color_y;
		if (color_mode == COLOR_MODE_RGB) {
			color_x = x.rgb;
			color_y = y.rgb;
		} else if (color_mode == COLOR_MODE_OKLAB) {
			color_x = rgb2oklab(x).rgb;
			color_y = rgb2oklab(y).rgb;
		} else if (color_mode == COLOR_MODE_OKLCH) {
			color_x = oklab2oklch(rgb2oklab(x)).rgb;
			color_y = oklab2oklch(rgb2oklab(y)).rgb;
		} else if (color_mode == COLOR_MODE_HSV) {
			color_x = rgb2hsv(x).rgb;
			color_y = rgb2hsv(y).rgb;
		}
		float divisor = 0.0;
		if (color_channel_mask[0]) {
			vx += color_x.r;
			vy += color_y.r;
			divisor += 1.0;
		}
		if (color_channel_mask[1]) {
			vx += color_x.g;
			vy += color_y.g;
			divisor += 1.0;
		}
		if (color_channel_mask[2]) {
			vx += color_x.b;
			vy += color_y.b;
			divisor += 1.0;
		}
		divisor = max(divisor, 1.0);
		vx /= divisor;
		vy /= divisor;
		//
		if (
			(a.x < .0 && abs(direction).y == .0) ||
			(a.y < .0 && abs(direction).x == .0)
		) {
			if (
				vy > vx &&
				// threshold
				color_x.r < upper_threshold[0] &&
				color_x.g < upper_threshold[1] &&
				color_x.b < upper_threshold[2] &&
				color_x.r > lower_threshold[0] &&
				color_x.g > lower_threshold[1] &&
				color_x.b > lower_threshold[2]
			) { return y; }
			else { return x; }
		} else if (
			(a.x > .0 && abs(direction).y == .0) ||
			(a.y > .0 && abs(direction).x == .0)
		) {
			if (
				vx >= vy &&
				// threshold
				color_y.r < upper_threshold[0] &&
				color_y.g < upper_threshold[1] &&
				color_y.b < upper_threshold[2] &&
				color_y.r > lower_threshold[0] &&
				color_y.g > lower_threshold[1] &&
				color_y.b > lower_threshold[2]
			) { return y; }
			else { return x; }
		}
	}
}
