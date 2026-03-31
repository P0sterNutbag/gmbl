shader_type canvas_item;

uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float vignette_radius : hint_range(0.0, 1.0) = 0.5;
uniform float vignette_softness : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    // Calculate distance from center
    vec2 uv = UV - vec2(0.5);
    float len = length(uv);

    // Create vignette effect
    float vignette = smoothstep(vignette_radius, vignette_radius - vignette_softness, len);

    // Apply color
    vec4 text = texture(TEXTURE, UV);
	text.a = 0.0;
    COLOR = mix(text, vignette_color, (1.0 - vignette) * vignette_color.a);
}
