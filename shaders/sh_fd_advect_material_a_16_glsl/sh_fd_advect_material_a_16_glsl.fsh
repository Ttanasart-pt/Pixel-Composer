#define USE_MACCORMACK_SCHEME true
#define FLOAT_16_OFFSET (128.0 / 255.0)

varying vec2 v_vTexcoord;

uniform sampler2D texture_velocity;
uniform sampler2D texture_world;

uniform vec2 texel_size;
uniform vec2 precalculated; // x: time_step * texel_size.x, y: time_step * texel_size.y.
uniform vec4 precalculated_1; // x: texel_size.x * 0.5, y: texel_size.y * 0.5, z: texel_size.x * -0.5, w: texel_size.y * -0.5.
uniform vec3 precalculated_2; // x: dissipation_type, y: dissipation_value, z: maccormack_weight * 0.5.

float unpack_ufloat_16(vec2 data) {return data.x + (data.y / 255.0);}
vec2 unpack_uvec2_16(vec4 data) {return vec2(data.xy + (data.zw / 255.0));}
vec2 pack_ufloat_16(float data) {return vec2(floor(data * 255.0) / 255.0, fract(data * 255.0));}

void main() {
    float velocity_range = 10.0;
    if (texture2D(texture_world, v_vTexcoord).w == 0.0) {
        vec2 velocity = (unpack_uvec2_16(texture2D(texture_velocity, v_vTexcoord)) - FLOAT_16_OFFSET) * velocity_range;
        
        vec2 from = v_vTexcoord - precalculated.xy * velocity;
        float phi_hat_next = unpack_ufloat_16(texture2D(gm_BaseTexture, from).wx);
        float color;
        
        if (USE_MACCORMACK_SCHEME) {
            vec2 phi_hat_next_velocity = (unpack_uvec2_16(texture2D(texture_velocity, from)) - FLOAT_16_OFFSET) * velocity_range;
            
            vec2 to = v_vTexcoord + precalculated.xy * phi_hat_next_velocity;
            float phi_hat_now = unpack_ufloat_16(texture2D(gm_BaseTexture, to).wx);
            
            color = phi_hat_next + (unpack_ufloat_16(texture2D(gm_BaseTexture, v_vTexcoord).wx) - phi_hat_now) * precalculated_2.z;
            
            vec2 coord = floor(from / texel_size + 0.5) * texel_size;
            float top_left = unpack_ufloat_16(texture2D(gm_BaseTexture, coord + precalculated_1.zw).wx);
            float bottom_right = unpack_ufloat_16(texture2D(gm_BaseTexture, coord + precalculated_1.xy).wx);
            float top_right = unpack_ufloat_16(texture2D(gm_BaseTexture, coord + precalculated_1.xw).wx);
            float bottom_left = unpack_ufloat_16(texture2D(gm_BaseTexture, coord + precalculated_1.zy).wx);
            color = clamp(color, min(min(min(top_left, top_right), bottom_left), bottom_right), max(max(max(top_left, top_right), bottom_left), bottom_right));
        } else {
            color = phi_hat_next;
        }
        
        if (precalculated_2.x < 0.5) color *= precalculated_2.y; else color -= precalculated_2.y;
        
        gl_FragColor.wx = pack_ufloat_16(color);
    } else {
        gl_FragColor.wx = vec2(0.0);
    }
}
