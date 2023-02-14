#define FLOAT_16_OFFSET (128.0 / 255.0)

varying vec2 v_vTexcoord;

uniform vec2 texel_size;
uniform vec2 precalculated; //x: 1.0 - relaxation_parameter, y: 0.25 * relaxation_parameter.

float unpack_ufloat_16(vec2 data) {return data.x + (data.y / 255.0);}
vec2 pack_ufloat_16(float data) {return vec2(floor(data * 255.0) / 255.0, fract(data * 255.0));}

void main() {
    float velocity_range = 10.0;
    float pressure_range = 10.0;

    gl_FragColor = texture2D(gm_BaseTexture, v_vTexcoord);
    float pressure = unpack_ufloat_16(gl_FragColor.xy) * pressure_range;
    float right = unpack_ufloat_16(texture2D(gm_BaseTexture, v_vTexcoord + vec2(texel_size.x, 0.0)).xy) * pressure_range;
    float left = unpack_ufloat_16(texture2D(gm_BaseTexture, v_vTexcoord - vec2(texel_size.x, 0.0)).xy) * pressure_range;
    float bottom = unpack_ufloat_16(texture2D(gm_BaseTexture, v_vTexcoord + vec2(0.0, texel_size.y)).xy) * pressure_range;
    float top = unpack_ufloat_16(texture2D(gm_BaseTexture, v_vTexcoord - vec2(0.0, texel_size.y)).xy) * pressure_range;
    
    float divergence = (unpack_ufloat_16(gl_FragColor.zw) - FLOAT_16_OFFSET) * velocity_range;
    
    pressure = precalculated.x * pressure + (left + right + top + bottom - divergence) * precalculated.y;
    
    gl_FragColor.xy = pack_ufloat_16(pressure / pressure_range);
}
