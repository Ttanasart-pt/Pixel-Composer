varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D bg, fg;
uniform float alpha;

void main() {
	vec4 c0 = texture2D( bg, v_vTexcoord );
	vec4 c1 = texture2D( fg, v_vTexcoord );
	c1.a *= alpha;
	
	gl_FragColor = c0;
	if(c1.a >= c0.a) gl_FragColor = c1;
}