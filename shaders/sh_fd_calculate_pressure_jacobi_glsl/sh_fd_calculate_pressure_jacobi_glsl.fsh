varying vec2 v_vTexcoord;

uniform vec2  texel_size;

uniform float max_force;

float clampForce(float v) { return clamp(v, -max_force, max_force); }
vec2  clampForce(vec2  v) { return vec2(clampForce(v.x), clampForce(v.y)); }

void main() {
    gl_FragColor.zw  = texture2D(gm_BaseTexture, v_vTexcoord).zw;
    float divergence = gl_FragColor.y;
    
    float right      = clampForce(texture2D(gm_BaseTexture, v_vTexcoord + vec2(texel_size.x, 0.0)).x);
    float left       = clampForce(texture2D(gm_BaseTexture, v_vTexcoord - vec2(texel_size.x, 0.0)).x);
    float bottom     = clampForce(texture2D(gm_BaseTexture, v_vTexcoord + vec2(0.0, texel_size.y)).x);
    float top        = clampForce(texture2D(gm_BaseTexture, v_vTexcoord - vec2(0.0, texel_size.y)).x);
    
    gl_FragColor.x  = (left + right + top + bottom - divergence) * 0.25;
}
