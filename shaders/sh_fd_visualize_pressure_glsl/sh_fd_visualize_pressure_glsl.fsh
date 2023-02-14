varying vec2 v_vTexcoord;
varying vec4 v_vColour;

float unpack_ufloat_16(vec2 data) {return data.x + (data.y / 255.0);}

void main() {
    float pressure = unpack_ufloat_16(texture2D(gm_BaseTexture, v_vTexcoord).xy);
    gl_FragColor = v_vColour * vec4(vec3(pressure), 1.0);
}
