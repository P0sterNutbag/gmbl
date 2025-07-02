shader_type spatial;

// This is a shader with less textures, in case the main one doesn't run on your GPU.
// It's mostly a big copy/paste, because Godot doesn't support #include or #ifdef...

#include "include/heightmap.gdshaderinc"

uniform sampler2D u_terrain_heightmap : hint_nearest;
uniform sampler2D u_terrain_normalmap : hint_nearest;
// I had to remove `hint_albedo` from colormap in Godot 3 because it makes sRGB conversion kick in,
// which snowballs to black when doing GPU painting on that texture...
uniform sampler2D u_terrain_colormap : hint_nearest;// : hint_albedo;
uniform sampler2D u_terrain_splatmap : hint_nearest;
uniform mat4 u_terrain_inverse_transform;
uniform mat3 u_terrain_normal_basis;

uniform sampler2D u_ground_albedo_bump_0 : source_color, hint_nearest;
uniform sampler2D u_ground_albedo_bump_1 : source_color, hint_nearest;
uniform sampler2D u_ground_albedo_bump_2 : source_color, hint_nearest;
uniform sampler2D u_ground_albedo_bump_3 : source_color, hint_nearest;

// ... existing code ... 