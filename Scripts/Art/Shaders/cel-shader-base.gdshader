shader_type spatial;

#define USE_ALPHA 0
#define USE_ALPHA_CUTOFF 0
#define USE_EMISSION 0
#define USE_REFLECTIONS 0
#define USE_NORMAL_MAP 0
#define USE_OCCLUSION 0
#define USE_ANISOTROPY 0
#define USE_BACKLIGHT 0
#define USE_REFRACTION 0

#if USE_ALPHA
render_mode depth_draw_always;
#endif

#include "includes/base-cel-shader.gdshaderinc"

#if USE_EMISSION
#include "includes/emission.gdshaderinc"
#endif

#if USE_REFLECTIONS
#include "includes/reflections.gdshaderinc"
#endif

#if USE_NORMAL_MAP
#include "includes/normal-map.gdshaderinc"
#endif

#if USE_OCCLUSION
#include "includes/occlusion.gdshaderinc"
#endif

#if USE_ANISOTROPY
#include "includes/anisotropy.gdshaderinc"
#endif

#if USE_BACKLIGHT
#include "includes/backlight.gdshaderinc"
#endif

#if USE_REFRACTION
#include "includes/refraction.gdshaderinc"
#elif !USE_REFRACTION && USE_ALPHA
#include "includes/transparency.gdshaderinc"
#endif

group_uniforms BaseProperties;
#if USE_ALPHA_CUTOFF
uniform float alpha_cutoff: hint_range(0.0, 1.0) = 0.5;
#endif
uniform vec4 color: source_color = vec4(0.7, 0.12, 0.86, 1.0);
uniform sampler2D base_texture: source_color, filter_nearest;
uniform vec4 specular: source_color = vec4(0.3, 0.3, 0.3, 0.5);
uniform sampler2D specular_texture: hint_default_white, filter_nearest;
uniform vec4 fresnel: source_color = vec4(0.2, 0.2, 0.2, 0.3);
uniform sampler2D fresnel_texture: hint_default_white, filter_nearest;
group_uniforms;

varying vec3 SPECULAR_COLOR;
varying float SPECULAR_STRENGTH;
varying vec3 FRESNEL_COLOR;
varying float FRESNEL_STRENGTH;

group_uniforms Tiling;
uniform vec2 uv_scale = vec2(1,1);
uniform vec2 uv_offset = vec2(0,0);
uniform bool use_triplanar = false;
uniform float triplanar_sharpness = 1.0;
group_uniforms;

// Triplanar mapping function
vec4 triplanar_texture(sampler2D tex, vec3 world_pos, vec3 normal, float sharpness) {
    vec3 blending = abs(normal);
    blending = normalize(max(blending, 0.00001)); // Force weights to sum to 1.0
    blending = pow(blending, vec3(sharpness));
    blending = blending / (blending.x + blending.y + blending.z);
    
    vec4 xaxis = texture(tex, world_pos.yz * uv_scale + uv_offset);
    vec4 yaxis = texture(tex, world_pos.xz * uv_scale + uv_offset);
    vec4 zaxis = texture(tex, world_pos.xy * uv_scale + uv_offset);
    
    return xaxis * blending.x + yaxis * blending.y + zaxis * blending.z;
}

void vertex() {
    if (!use_triplanar) {
        UV = UV * uv_scale.xy + uv_offset.xy;
    }
}

void fragment() {
    vec4 base_tex;
    vec4 spec_tex;
    vec4 fres_tex;
    
    if (use_triplanar) {
        base_tex = triplanar_texture(base_texture, WORLD_POSITION, NORMAL, triplanar_sharpness);
        spec_tex = triplanar_texture(specular_texture, WORLD_POSITION, NORMAL, triplanar_sharpness);
        fres_tex = triplanar_texture(fresnel_texture, WORLD_POSITION, NORMAL, triplanar_sharpness);
    } else {
        base_tex = texture(base_texture, UV);
        spec_tex = texture(specular_texture, UV);
        fres_tex = texture(fresnel_texture, UV);
    }
    
    ALBEDO = color.rgb * base_tex.rgb;
#if USE_ALPHA
    float alpha = color.a * base_tex.a;
    ALBEDO *= alpha;
#elif USE_ALPHA_CUTOFF
    ALPHA = color.a * base_tex.a;
    ALPHA_SCISSOR_THRESHOLD = color.a * base_tex.a;
#endif

#if USE_REFRACTION && USE_ALPHA
    EMISSION += refraction_fragment(alpha, NORMAL, SCREEN_UV, FRAGCOORD.z);
#elif !USE_REFRACTION && USE_ALPHA
    EMISSION += transparency_fragment(alpha, SCREEN_UV);
#endif

    SPECULAR_COLOR = specular.rgb * spec_tex.rgb;
    SPECULAR_STRENGTH = specular.a * spec_tex.a;
    FRESNEL_COLOR = fresnel.rgb * fres_tex.rgb;
    FRESNEL_STRENGTH = fresnel.a * fres_tex.a;

#if USE_EMISSION
    EMISSION += emission_fragment(UV);
#endif

#if USE_REFLECTIONS
    Surface surf = reflections_fragment(UV);
    METALLIC = surf.metallic;
    ROUGHNESS = surf.roughness;
#endif

#if USE_NORMAL_MAP
    NormalData normal = normal_map_fragment(UV, NORMAL, TANGENT, BINORMAL);
    NORMAL = normal.vector;
    NORMAL_MAP = normal.map;
    NORMAL_MAP_DEPTH = normal.depth;
#endif

#if USE_OCCLUSION
    OcclusionData occlusion = occlusion_fragment(UV);
    AO = occlusion.ao;
    AO_LIGHT_AFFECT = occlusion.ao_light_affect;
#endif

#if USE_ANISOTROPY
    AnisotropyData aniso = anisotropy_fragment(UV);
    ANISOTROPY_DIR = aniso.direction;
    ANISOTROPY_RATIO = aniso.ratio;
#endif

#if USE_BACKLIGHT
    BACKLIGHT = backlight_fragment(UV);
#endif
} 