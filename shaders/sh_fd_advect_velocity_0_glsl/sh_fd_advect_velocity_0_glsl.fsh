#define USE_ACCELERATION_FIELD false
#define USE_MACCORMACK_SCHEME true
#define FLOAT_16_OFFSET (128.0 / 255.0)
#define FLOAT_8_OFFSET (128.0 / 255.0)

varying vec2 v_vTexcoord;

uniform sampler2D texture_world;

uniform vec4 precalculated; // x: time_step * texel_size.x, y: time_step * texel_size.y, z: texel_size.x, w: texel_size.y.
uniform vec3 precalculated_1; // x: velocity_dissipation_type, y: velocity_dissipation_value, z: velocity_maccormack_weight * 0.5.
uniform vec2 acceleration;

vec2 unpack_uvec2_16(vec4 data) {return vec2(data.xy + (data.zw / 255.0));}
vec4 pack_uvec2_16(vec2 data) {return vec4(floor(data * 255.0) / 255.0, fract(data * 255.0));}

void main() {
    float velocity_range = 10.0;

    vec2 velocity = (unpack_uvec2_16(texture2D(gm_BaseTexture, v_vTexcoord)) - FLOAT_16_OFFSET) * velocity_range;

    vec2 from = v_vTexcoord - precalculated.xy * velocity;
    vec2 phi_hat_next = (unpack_uvec2_16(texture2D(gm_BaseTexture, from)) - FLOAT_16_OFFSET) * velocity_range;
    
    if (USE_MACCORMACK_SCHEME) {
        vec2 phi_hat_now = (unpack_uvec2_16(texture2D(gm_BaseTexture, v_vTexcoord + precalculated.xy * phi_hat_next)) - FLOAT_16_OFFSET) * velocity_range;
        velocity = phi_hat_next + (velocity - phi_hat_now) * precalculated_1.z;
        
        vec2 coord = floor(from / precalculated.zw + 0.5) * precalculated.zw;
        vec2 top_left = (unpack_uvec2_16(texture2D(gm_BaseTexture, coord + vec2(-precalculated.z, -precalculated.w) * 0.5)) - FLOAT_16_OFFSET) * velocity_range;
        vec2 bottom_right = (unpack_uvec2_16(texture2D(gm_BaseTexture, coord + vec2(precalculated.z, precalculated.w) * 0.5)) - FLOAT_16_OFFSET) * velocity_range;
        vec2 top_right = (unpack_uvec2_16(texture2D(gm_BaseTexture, coord + vec2(precalculated.z, -precalculated.w) * 0.5)) - FLOAT_16_OFFSET) * velocity_range;
        vec2 bottom_left = (unpack_uvec2_16(texture2D(gm_BaseTexture, coord + vec2(-precalculated.z, precalculated.w) * 0.5)) - FLOAT_16_OFFSET) * velocity_range;
        velocity = clamp(velocity, min(min(min(top_left, top_right), bottom_left), bottom_right), max(max(max(top_left, top_right), bottom_left), bottom_right));
    } else {
        velocity = phi_hat_next;
    }
    
    if (precalculated_1.x < 0.5) velocity *= precalculated_1.y;
    else {
        if (velocity.x > 0.0) velocity.x = max(0.0, velocity.x - precalculated_1.y); else velocity.x = min(0.0, velocity.x + precalculated_1.y);
        if (velocity.y > 0.0) velocity.y = max(0.0, velocity.y - precalculated_1.y); else velocity.y = min(0.0, velocity.y + precalculated_1.y);
    }
    
    vec3 world = texture2D(texture_world, v_vTexcoord).xyw;
    
    velocity += acceleration.xy + (world.xy - FLOAT_8_OFFSET) * float(USE_ACCELERATION_FIELD);
    
    if (world.z != 0.0) velocity = vec2(0.0, 0.0);
    
    gl_FragColor = pack_uvec2_16(clamp(velocity / velocity_range + FLOAT_16_OFFSET, 0.0, 1.0));
}
