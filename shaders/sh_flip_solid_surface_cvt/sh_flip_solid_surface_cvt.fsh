varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float threshold;

void main() {
	vec4  s = texture2D(gm_BaseTexture, v_vTexcoord);
	float w = (s.r + s.g + s.b) / .3 * s.a;
	
	gl_FragColor = vec4(step(threshold, w), 0., 0., 1.);
}