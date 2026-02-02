varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D bg;
uniform sampler2D fg;
uniform float amo;

void main() {
	vec2 uv0 = texture2D(bg, v_vTexcoord).xy;
	vec2 uv1 = texture2D(fg, v_vTexcoord).xy;
	
	gl_FragColor = vec4(mix(uv0, uv1, amo), 0., 1.);
}