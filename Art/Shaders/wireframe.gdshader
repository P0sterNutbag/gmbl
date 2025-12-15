shader_type spatial;
render_mode blend_mix, unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, filter_linear;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_linear;

uniform float depth_edge_threshold_lower: hint_range(0.0, 1.0, 0.01) = 0.15;
uniform float depth_edge_threshold_upper: hint_range(0.0, 45.0, 0.05) = 0.3;
uniform float normal_edge_threshold: hint_range(0.0, 1.0, 0.1) = 0.5;
uniform vec3 line_color: source_color = vec3(0.41, 0.37, 0.42);
uniform float line_width: hint_range(0.1, 4.0, 0.1) = 1.0;

// --- Fog parameters ---
uniform vec3 fog_color: source_color = vec3(0.7, 0.75, 0.8);
uniform float fog_start: hint_range(0.0, 500.0, 1.0) = 30.0;
uniform float fog_end: hint_range(0.0, 2000.0, 1.0) = 300.0;

const mat3 sobel_y = mat3(
	vec3(1.0, 0.0, -1.0),
	vec3(2.0, 0.0, -2.0),
	vec3(1.0, 0.0, -1.0)
);

const mat3 sobel_x = mat3(
	vec3(1.0, 2.0, 1.0),
	vec3(0.0, 0.0, 0.0),
	vec3(-1.0, -2.0, -1.0)
);

// --- Linearize depth from depth texture ---
float linearize_depth(vec2 uv_coord, mat4 proj_matrix){
	float depth = texture(DEPTH_TEXTURE, uv_coord).x;
	vec3 ndc = vec3(uv_coord * 2.0 - 1.0, depth);
	vec4 view = proj_matrix * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return -view.z;
}

vec3 normalize_normal(vec3 normal){
	return normalize(normal * 2.0 - 1.0);
}

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 screen_color = texture(SCREEN_TEXTURE, uv);
	vec2 screen_pixel_size = 0.5 / VIEWPORT_SIZE * line_width;

	// --- depth edge detection ---
	float depth = linearize_depth(uv, INV_PROJECTION_MATRIX);
	float n = linearize_depth(uv + vec2(0.0, -screen_pixel_size.y), INV_PROJECTION_MATRIX);
	float s = linearize_depth(uv + vec2(0.0, screen_pixel_size.y), INV_PROJECTION_MATRIX);
	float e = linearize_depth(uv + vec2(screen_pixel_size.x, 0.0), INV_PROJECTION_MATRIX);
	float w = linearize_depth(uv + vec2(-screen_pixel_size.x, 0.0), INV_PROJECTION_MATRIX);
	float nw = linearize_depth(uv + vec2(-screen_pixel_size.x, -screen_pixel_size.y), INV_PROJECTION_MATRIX);
	float ne = linearize_depth(uv + vec2(screen_pixel_size.x, -screen_pixel_size.y), INV_PROJECTION_MATRIX);
	float sw = linearize_depth(uv + vec2(-screen_pixel_size.x, screen_pixel_size.y), INV_PROJECTION_MATRIX);
	float se = linearize_depth(uv + vec2(screen_pixel_size.x, screen_pixel_size.y), INV_PROJECTION_MATRIX);

	mat3 depth_surrounding_pixels = mat3(
		vec3(nw, n, ne),
		vec3(w, depth, e),
		vec3(sw, s, se)
	);

	float depth_edge_x = dot(sobel_x[0], depth_surrounding_pixels[0]) + dot(sobel_x[1], depth_surrounding_pixels[1]) + dot(sobel_x[2], depth_surrounding_pixels[2]);
	float depth_edge_y = dot(sobel_y[0], depth_surrounding_pixels[0]) + dot(sobel_y[1], depth_surrounding_pixels[1]) + dot(sobel_y[2], depth_surrounding_pixels[2]);
	float depth_edge = sqrt(pow(depth_edge_x, 2.0) + pow(depth_edge_y, 2.0)) / max(0.001, depth);

	// --- normal edge detection ---
	vec3 normal = normalize_normal(texture(NORMAL_TEXTURE, uv).rgb);
	vec3 n_n = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(0.0, -screen_pixel_size.y)).rgb);
	vec3 n_s = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(0.0, screen_pixel_size.y)).rgb);
	vec3 n_e = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(screen_pixel_size.x, 0.0)).rgb);
	vec3 n_w = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(-screen_pixel_size.x, 0.0)).rgb);
	vec3 n_nw = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(-screen_pixel_size.x, -screen_pixel_size.y)).rgb);
	vec3 n_ne = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(screen_pixel_size.x, -screen_pixel_size.y)).rgb);
	vec3 n_sw = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(-screen_pixel_size.x, screen_pixel_size.y)).rgb);
	vec3 n_se = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(screen_pixel_size.x, screen_pixel_size.y)).rgb);

	mat3 normal_surrounding_pixels = mat3(
		vec3(length(n_nw-normal), length(n_n-normal), length(n_ne-normal)),
		vec3(length(n_w-normal), length(normal-normal), length(n_e-normal)),
		vec3(length(n_sw-normal), length(n_s-normal), length(n_se-normal))
	);

	float normal_edge_x = dot(sobel_x[0], normal_surrounding_pixels[0]) + dot(sobel_x[1], normal_surrounding_pixels[1]) + dot(sobel_x[2], normal_surrounding_pixels[2]);
	float normal_edge_y = dot(sobel_y[0], normal_surrounding_pixels[0]) + dot(sobel_y[1], normal_surrounding_pixels[1]) + dot(sobel_y[2], normal_surrounding_pixels[2]);
	float normal_edge = sqrt(pow(normal_edge_x, 2.0) + pow(normal_edge_y, 2.0));

	// --- fog using linear depth ---
	float fog_factor = smoothstep(fog_start, fog_end, depth);
	vec3 fogged_color = mix(screen_color.rgb, fog_color, fog_factor);

	// --- final color: fog drawn on top of outlines ---
	vec3 final_color;
	float final_alpha;

	if (normal_edge > normal_edge_threshold || (depth_edge > depth_edge_threshold_lower && normal_edge > 0.0) || depth_edge > depth_edge_threshold_upper) {
		final_color = mix(line_color, fogged_color, fog_factor);
		final_alpha = 1.0; // keep wireframe fully opaque
	} else {
		final_color = fogged_color;
		final_alpha = screen_color.a;
	}

	ALBEDO = final_color;
	ALPHA = final_alpha;
}