#define USE_MACCORMACK_SCHEME true
#define FLOAT_16_OFFSET (128.0 / 255.0)
#define COLOR_OUTSIDE vec4(0.714, 0.714, 0.714, 0.0)

varying vec2 v_vTexcoord;

uniform sampler2D texture_velocity;
uniform sampler2D texture_world;

uniform float dissipation_type;
uniform float dissipation_value;
uniform float maccormack_weight_half;
uniform vec2 texel_size;
uniform vec4 precalculated; // x: time_step * texel_size.x, y: time_step * texel_size.y.
uniform vec4 precalculated_1; // x: texel_size.x * 0.5, y: texel_size.y * 0.5, z: texel_size.x * -0.5, w: texel_size.y * -0.5.

vec2 unpack_uvec2_16(vec4 data) {return vec2(data.xy + (data.zw / 255.0));}

void main() {
    float velocity_range = 10.0;
    if (texture2D(texture_world, v_vTexcoord).w == 0.0) {
        vec2 velocity = (unpack_uvec2_16(texture2D(texture_velocity, v_vTexcoord)) - FLOAT_16_OFFSET) * velocity_range;
        
        vec2 from = v_vTexcoord - precalculated.xy * velocity;
        vec4 phi_hat_next = texture2D(gm_BaseTexture, from);
        vec4 color;
        
        if (USE_MACCORMACK_SCHEME) {
            vec2 phi_hat_next_velocity = (unpack_uvec2_16(texture2D(texture_velocity, from)) - FLOAT_16_OFFSET) * velocity_range;
            
            vec2 to = v_vTexcoord + precalculated.xy * phi_hat_next_velocity;
            vec4 phi_hat_now = texture2D(gm_BaseTexture, to);
            
            color = phi_hat_next + (texture2D(gm_BaseTexture, v_vTexcoord) - phi_hat_now) * maccormack_weight_half;
            
            vec2 coord = floor(from / texel_size + 0.5) * texel_size;
            vec4 top_left = texture2D(gm_BaseTexture, coord + precalculated_1.zw);
            vec4 bottom_right = texture2D(gm_BaseTexture, coord + precalculated_1.xy);
            vec4 top_right = texture2D(gm_BaseTexture, coord + precalculated_1.xw);
            vec4 bottom_left = texture2D(gm_BaseTexture, coord + precalculated_1.zy);
            color = clamp(color, min(min(min(top_left, top_right), bottom_left), bottom_right), max(max(max(top_left, top_right), bottom_left), bottom_right));
        } else {
            color = phi_hat_next;
        }
        
        if (dissipation_type < 0.5) color *= dissipation_value; else color -= dissipation_value;
        
        gl_FragColor = color;
    } else {
        gl_FragColor = COLOR_OUTSIDE;
    }
}
