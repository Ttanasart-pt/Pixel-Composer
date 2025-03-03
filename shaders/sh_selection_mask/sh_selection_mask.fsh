varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float index;

void main() {
	vec4 samp = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = vec4(index * (samp.a > .5? 1. : 0.), 0., 0., 1.);
}