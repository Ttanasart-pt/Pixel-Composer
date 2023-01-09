//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;

uniform vec2 UVscale;
uniform vec2 UVshift;

void main() {
    gl_FragColor = texture2D( gm_BaseTexture, 1. - fract((v_vTexcoord + UVshift) * UVscale) );
}
