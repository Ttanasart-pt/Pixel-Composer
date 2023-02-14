#define FLOAT_16_OFFSET (128.0 / 255.0)

varying vec2 v_vTexcoord;

uniform sampler2D texture_pressure;

uniform vec2 texel_size;

vec2 unpack_uvec2_16(vec4 data) {return vec2(data.xy + (data.zw / 255.0));}
vec4 pack_uvec2_16(vec2 data) {return vec4(floor(data * 255.0) / 255.0, fract(data * 255.0));}
float unpack_ufloat_16(vec2 data) {return data.x + (data.y / 255.0);}

void main() {
    float velocity_range = 10.0;
    float pressure_range = 10.0;
    
    float right = unpack_ufloat_16(texture2D(texture_pressure, v_vTexcoord + vec2(texel_size.x, 0.0)).xy) * pressure_range;
    float left = unpack_ufloat_16(texture2D(texture_pressure, v_vTexcoord - vec2(texel_size.x, 0.0)).xy) * pressure_range;
    float bottom = unpack_ufloat_16(texture2D(texture_pressure, v_vTexcoord + vec2(0.0, texel_size.y)).xy) * pressure_range;
    float top = unpack_ufloat_16(texture2D(texture_pressure, v_vTexcoord - vec2(0.0, texel_size.y)).xy) * pressure_range;
    
    vec2 gradient = 0.5 * vec2(right - left, bottom - top);
    
    vec2 velocity = (unpack_uvec2_16(texture2D(gm_BaseTexture, v_vTexcoord)) - FLOAT_16_OFFSET) * velocity_range;
    
    velocity -= gradient;
    
    gl_FragColor = pack_uvec2_16(clamp(velocity / velocity_range + FLOAT_16_OFFSET, 0.0, 1.0));
}
