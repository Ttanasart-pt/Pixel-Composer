varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float scaleFactor;

void main() {
	vec2 stx  = (1. / scaleFactor) / dimension;
	vec4 accu = vec4(0.);
	
	for(float _x = 0.; _x < scaleFactor; _x++)
	for(float _y = 0.; _y < scaleFactor; _y++) {
		vec2 tx = v_vTexcoord + vec2(_x, _y) * stx;
		accu += texture2D(gm_BaseTexture, tx);
	}
	
	gl_FragColor = accu;
}