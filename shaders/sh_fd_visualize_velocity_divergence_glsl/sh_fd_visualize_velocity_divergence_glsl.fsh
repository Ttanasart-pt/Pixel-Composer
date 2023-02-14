#define FLOAT_16_OFFSET (128.0 / 255.0)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

float unpack_ufloat_16(vec2 data) {return data.x + (data.y / 255.0);}

void main() {
    float divergence = unpack_ufloat_16(texture2D(gm_BaseTexture, v_vTexcoord).zw) - FLOAT_16_OFFSET;
    gl_FragColor = v_vColour * vec4(vec3(divergence + FLOAT_16_OFFSET), 1.0);
}
