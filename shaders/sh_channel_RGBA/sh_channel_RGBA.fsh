varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int keepAlpha;

void main() {
    gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord ) * v_vColour;
    if(keepAlpha == 0) gl_FragColor.a = 1.;
}
