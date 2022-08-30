//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D map;

void main() {
	vec2 pos = texture2D( map, v_vTexcoord ).rg;
    gl_FragColor = texture2D( gm_BaseTexture, vec2(1. - pos.x, pos.y) );
}
