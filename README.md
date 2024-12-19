
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
//!load <name> <filepath>
uniform sampler2D <name>;
```

Have a look at the `mix.gdshader` example:

```glsl
shader_type canvas_item;

//!load ./example1.png

//!load+ img2 ./example2.jpg
uniform sampler2D img2: repeat_enable, filter_nearest;

void fragment() {
	COLOR = mix(COLOR, texture(img2, UV), .5);
}
```
