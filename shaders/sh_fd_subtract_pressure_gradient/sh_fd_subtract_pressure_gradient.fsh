varying vec2 v_vTexcoord;

uniform sampler2D texture_pressure;
uniform vec2  texel_size;

uniform float max_force;
uniform int   repeat;
uniform int   wall;

float clampForce(float v) { return clamp(v, -max_force, max_force); }
vec2  clampForce(vec2  v) { return vec2(clampForce(v.x), clampForce(v.y)); }

void main() {
    float right  = texture2D(texture_pressure, v_vTexcoord + vec2(texel_size.x, 0.0)).x;
    float left   = texture2D(texture_pressure, v_vTexcoord - vec2(texel_size.x, 0.0)).x;
    float bottom = texture2D(texture_pressure, v_vTexcoord + vec2(0.0, texel_size.y)).x;
    float top    = texture2D(texture_pressure, v_vTexcoord - vec2(0.0, texel_size.y)).x;
    
    vec2 gradient = 0.5 * vec2(right - left, bottom - top);
    vec2 velocity = clampForce(texture2D(gm_BaseTexture, v_vTexcoord).xy);
    
    velocity -= gradient;
    
    gl_FragColor = vec4(clampForce(velocity), 0.0, 1.0);
}
