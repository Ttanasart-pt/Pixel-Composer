//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D map;

void main() {
	vec4 map = texture2D( map, v_vTexcoord );
	vec2 pos = map.rg;
	
	vec4 samp = texture2D( gm_BaseTexture, vec2(1. - pos.x, pos.y) );
	samp.a *= map.a;
	
    gl_FragColor = samp;
}
