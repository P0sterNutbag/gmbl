shader_type canvas_item;

// ✅ This is the modern replacement for SCREEN_TEXTURE
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float pixel_size = 4.0;
uniform int color_steps = 4;
uniform bool enable_dither = true;

// Bayer 4x4 dithering pattern
float bayer_dither4(vec2 pos) {
    int x = int(mod(pos.x, 4.0));
    int y = int(mod(pos.y, 4.0));
    int i = y * 4 + x;

    float bayer[16] = float[](
        0.0,  8.0,  2.0, 10.0,
       12.0,  4.0, 14.0,  6.0,
        3.0, 11.0,  1.0,  9.0,
       15.0,  7.0, 13.0,  5.0
    );

    return bayer[i] / 16.0;
}

void fragment() {
    vec2 screen_uv = SCREEN_UV;

    // Calculate pixel grid
    vec2 resolution = vec2(1.0) / textureSize(SCREEN_TEXTURE, 0); // pixel size
    screen_uv = floor(screen_uv / (pixel_size * resolution)) * (pixel_size * resolution);

    // Sample the screen
    vec4 color = texture(SCREEN_TEXTURE, screen_uv);

    // Color banding
    vec3 banded = floor(color.rgb * float(color_steps)) / float(color_steps);

    // Optional dithering
    if (enable_dither) {
        float threshold = bayer_dither4(screen_uv * textureSize(SCREEN_TEXTURE, 0));
        vec3 dithered = floor((color.rgb * float(color_steps) + vec3(threshold))) / float(color_steps);
        COLOR = vec4(dithered, color.a);
    } else {
        COLOR = vec4(banded, color.a);
    }
} 