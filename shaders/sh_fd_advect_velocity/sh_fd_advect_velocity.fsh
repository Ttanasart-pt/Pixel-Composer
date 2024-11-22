#define USE_ACCELERATION_FIELD false
#define USE_MACCORMACK_SCHEME true

varying vec2 v_vTexcoord;

uniform int mode;
uniform int repeat;
uniform int wall;
uniform sampler2D texture_world;
uniform sampler2D texture_material;

uniform vec2 texel_size;      // x: time_step * texel_size.x,  y: time_step * texel_size.y,   z: texel_size.x, w: texel_size.y.
uniform vec4 precalculated;   // x: time_step * texel_size.x,  y: time_step * texel_size.y,   z: texel_size.x, w: texel_size.y.
uniform vec3 precalculated_1; // x: velocity_dissipation_type, y: velocity_dissipation_value, z: velocity_maccormack_weight * 0.5.
uniform vec4 acceleration;

uniform float max_force;

float clampForce(float v) { return clamp(v, -max_force, max_force); }
vec2  clampForce(vec2  v) { return vec2(clampForce(v.x), clampForce(v.y)); }

void main() {
    vec2 velocity = clampForce(texture2D(gm_BaseTexture, v_vTexcoord).xy);

    vec2 from         = v_vTexcoord - precalculated.xy * velocity;
    vec2 phi_hat_next = clampForce(texture2D(gm_BaseTexture, from).xy);
         velocity     = phi_hat_next;
    
    if (USE_MACCORMACK_SCHEME) {
        vec2 phi_hat_now = clampForce(texture2D(gm_BaseTexture, v_vTexcoord + precalculated.xy * phi_hat_next).xy);
        velocity = phi_hat_next + (velocity - phi_hat_now) * precalculated_1.z;
        
        vec2 coord        = floor(from / precalculated.zw + 0.5) * precalculated.zw;
        vec2 top_left     = clampForce(texture2D(gm_BaseTexture, coord + vec2(-precalculated.z, -precalculated.w) * 0.5).xy);
        vec2 bottom_right = clampForce(texture2D(gm_BaseTexture, coord + vec2( precalculated.z,  precalculated.w) * 0.5).xy);
        vec2 top_right    = clampForce(texture2D(gm_BaseTexture, coord + vec2( precalculated.z, -precalculated.w) * 0.5).xy);
        vec2 bottom_left  = clampForce(texture2D(gm_BaseTexture, coord + vec2(-precalculated.z,  precalculated.w) * 0.5).xy);
        
        velocity = clamp(velocity, min(min(min(top_left, top_right), bottom_left), bottom_right), max(max(max(top_left, top_right), bottom_left), bottom_right));
    }
    
    if (precalculated_1.x < 0.5) velocity *= precalculated_1.y;
    else {
        if (velocity.x > 0.0) velocity.x = max(0.0, velocity.x - precalculated_1.y); else velocity.x = min(0.0, velocity.x + precalculated_1.y);
        if (velocity.y > 0.0) velocity.y = max(0.0, velocity.y - precalculated_1.y); else velocity.y = min(0.0, velocity.y + precalculated_1.y);
    }
    
    vec3 world = texture2D(texture_world, v_vTexcoord).xyw;
    
    if(mode == 0) {
        velocity += acceleration.xy + world.xy * float(USE_ACCELERATION_FIELD);
        
    } else if(mode == 1) {
        float amount = texture2D(texture_material, v_vTexcoord).w;
        velocity += acceleration.xy * (acceleration.z * amount * amount + acceleration.w * amount) + world.xy * float(USE_ACCELERATION_FIELD);
    }
    
    if(world.z != 0.0) {
        velocity = vec2(0.0, 0.0);
    }
    
    if(wall == 1) {
        if(v_vTexcoord.x < texel_size.x || v_vTexcoord.y < texel_size.x || v_vTexcoord.x > 1. - texel_size.y || v_vTexcoord.y > 1. - texel_size.y)
        velocity = vec2(0.0, 0.0);
    }
    
    gl_FragColor = vec4(clampForce(velocity), 0., 0.);
}
