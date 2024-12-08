// Passthrough vertex shader.

attribute vec4 in_Position;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;

void main() {
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_vTexcoord;

uniform vec2  texel_size;
uniform vec2  precalculated; //x: 1.0 - relaxation_parameter, y: 0.25 * relaxation_parameter.

uniform int   repeat;
uniform int   wall;
uniform float max_force;

float clampForce(float v) { return clamp(v, -max_force, max_force); }
vec2  clampForce(vec2  v) { return vec2(clampForce(v.x), clampForce(v.y)); }

void main() {
    gl_FragColor     = texture2D(gm_BaseTexture, v_vTexcoord);
    float pressure   = gl_FragColor.x;
    float divergence = gl_FragColor.y;
    
    float right    = texture2D(gm_BaseTexture, v_vTexcoord + vec2(texel_size.x, 0.0)).x;
    float left     = texture2D(gm_BaseTexture, v_vTexcoord - vec2(texel_size.x, 0.0)).x;
    float bottom   = texture2D(gm_BaseTexture, v_vTexcoord + vec2(0.0, texel_size.y)).x;
    float top      = texture2D(gm_BaseTexture, v_vTexcoord - vec2(0.0, texel_size.y)).x;
    
    pressure = precalculated.x * pressure + (left + right + top + bottom - divergence) * precalculated.y;
    
    gl_FragColor.x = pressure;
}

