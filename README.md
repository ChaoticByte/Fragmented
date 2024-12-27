
<h1 align=center>Fragmented</h1>

![screenshot](./screenshot.png)

<p align=center>Create image filters by writing shaders.</p>

## Supported Platforms

- Linux

You can find the latest releases [here](https://github.com/ChaoticByte/Fragmented/releases/latest).

## Usage

The repo includes examples. You can use them as a starting-point to write your own filters.  
Just load an image using `//!load`, edit the shader code and hit `F5` to see the changes.

### Load TEXTURE using the `//!load` directive

```glsl
//!load <filepath>
```

The image file will be read and available as the `TEXTURE` variable.

#### Load additional images

```glsl
//!load+ <name> <filepath>
uniform sampler2D <name>;
```

Have a look at the `place_texture.gdshader` example:

```glsl
shader_type canvas_item;

#include "res://shaderlib/transform.gdshaderinc"

//!load ./swamp.jpg
//!load+ img2 ./grass.png

uniform sampler2D img2: repeat_disable, filter_nearest;

void fragment() {
	vec4 grass = place_texture(img2, UV, TEXTURE_PIXEL_SIZE, vec2(0, .47), vec2(1));
	grass.rgb += (vec3(0.03, 0.07, 0.11) - ((UV.y - .8) * 0.15)); // color correction
	COLOR.rgb = mix(COLOR.rgb, grass.rgb, grass.a);
}
```

## Shaderlib

This repo comes with a (still small) shader library including pre-written functions and more.
Have a look at the `shaderlib` folder.

Here is an example on how to use it (the `hsv.gdshader` example):

```glsl
shader_type canvas_item;

#include "res://shaderlib/hsv.gdshaderinc"

//!load ./swamp.jpg

void fragment() {
	COLOR = hsv_offset(COLOR, 0.32, 0.2, 0.0);
}
```
