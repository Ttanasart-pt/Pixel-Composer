#define FLOAT_16_OFFSET (128.0 / 255.0)

varying vec2 v_vTexcoord;

uniform float initial_value_pressure;
uniform vec2 texel_size;

vec2 unpack_uvec2_16(vec4 data) {return vec2(data.xy + (data.zw / 255.0));}
vec2 pack_ufloat_16(float data) {return vec2(floor(data * 255.0) / 255.0, fract(data * 255.0));}

void main() {
    vec2 right = unpack_uvec2_16(texture2D(gm_BaseTexture, v_vTexcoord + vec2(texel_size.x, 0.0))) - FLOAT_16_OFFSET;
    vec2 left = unpack_uvec2_16(texture2D(gm_BaseTexture, v_vTexcoord - vec2(texel_size.x, 0.0))) - FLOAT_16_OFFSET;
    vec2 bottom = unpack_uvec2_16(texture2D(gm_BaseTexture, v_vTexcoord + vec2(0.0, texel_size.y))) - FLOAT_16_OFFSET;
    vec2 top = unpack_uvec2_16(texture2D(gm_BaseTexture, v_vTexcoord - vec2(0.0, texel_size.y))) - FLOAT_16_OFFSET;
    
    gl_FragColor = vec4(initial_value_pressure, 0.0, pack_ufloat_16(clamp((0.5 * ((right.x - left.x) + (bottom.y - top.y))) + FLOAT_16_OFFSET, 0.0, 1.0)));
}
