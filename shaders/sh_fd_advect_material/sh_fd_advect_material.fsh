#define USE_MACCORMACK_SCHEME true

varying vec2 v_vTexcoord;

uniform sampler2D texture_velocity;
uniform sampler2D texture_world;

uniform int  repeat;
uniform int  wall;
uniform vec2 texel_size;
uniform vec2 precalculated; // x: time_step * texel_size.x, y: time_step * texel_size.y.
uniform vec4 precalculated_1; // x: texel_size.x * 0.5, y: texel_size.y * 0.5, z: texel_size.x * -0.5, w: texel_size.y * -0.5.
uniform vec3 precalculated_2; // x: dissipation_type, y: dissipation_value, z: maccormack_weight * 0.5.

uniform float max_force;

float clampForce(float v) { return clamp(v, -max_force, max_force); }
vec2  clampForce(vec2  v) { return vec2(clampForce(v.x), clampForce(v.y)); }

void main() {
    gl_FragColor = vec4(0.0);
    
    if (texture2D(texture_world, v_vTexcoord).w != 0.0) return;
    
    vec2  velocity     = clampForce(texture2D(texture_velocity, v_vTexcoord).xy);
    vec2  from         = v_vTexcoord - precalculated.xy * velocity;
    float phi_hat_next = texture2D(gm_BaseTexture, from).w;
    float color        = phi_hat_next;
    
    if (USE_MACCORMACK_SCHEME) {
        vec2 phi_hat_next_velocity = clampForce(texture2D(texture_velocity, from).xy);
        
        vec2  to = v_vTexcoord + precalculated.xy * phi_hat_next_velocity;
        float phi_hat_now = texture2D(gm_BaseTexture, to).w;
        
        color = phi_hat_next + (texture2D(gm_BaseTexture, v_vTexcoord).w - phi_hat_now) * precalculated_2.z;
        
        vec2  coord        = floor(from / texel_size + 0.5) * texel_size;
        float top_left     = clamp(texture2D(gm_BaseTexture, coord + precalculated_1.zw).w, 0., 1.);
        float bottom_right = clamp(texture2D(gm_BaseTexture, coord + precalculated_1.xy).w, 0., 1.);
        float top_right    = clamp(texture2D(gm_BaseTexture, coord + precalculated_1.xw).w, 0., 1.);
        float bottom_left  = clamp(texture2D(gm_BaseTexture, coord + precalculated_1.zy).w, 0., 1.);
        
        color = clamp(color, min(min(min(top_left, top_right), bottom_left), bottom_right), max(max(max(top_left, top_right), bottom_left), bottom_right));
    }
    
    if (precalculated_2.x < 0.5) 
         color *= precalculated_2.y; 
    else color -= precalculated_2.y;
    
    gl_FragColor.w = color;
}
