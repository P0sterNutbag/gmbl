shader_type canvas_item;

render_mode unshaded;

uniform bool enabled = true;
uniform bool dithering = true;
uniform int dither_size: hint_range(1, 8) = 1;

float dithering_pattern(ivec2 fragcoord) {
	const float pattern[] = {
		0.00, 0.50, 0.10, 0.65, 
		0.75, 0.25, 0.90, 0.35, 
		0.20, 0.70, 0.05, 0.50, 
		0.95, 0.40, 0.80, 0.30
	};
	int x = fragcoord.x % 4;
	int y = fragcoord.y % 4;
	return pattern[y * 4 + x];
}

void fragment() {
	vec4 raw = texture(TEXTURE, SCREEN_UV);
	ivec2 uv = ivec2(FRAGCOORD.xy / float(dither_size));

	if (enabled) {
		vec3 color = raw.rgb;

		if (dithering) {
			float dither = (dithering_pattern(uv) - 0.5) * 0.05; // Subtle noise
			color += vec3(dither);
		}

		COLOR.rgb = clamp(color, 0.0, 1.0);
	} else {
		COLOR.rgb = raw.rgb;
	}
}
