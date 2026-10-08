varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int filter;

void main() {
	vec4 base = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	float val = length(base.rgb) * base.a;
	
	gl_FragColor = vec4(0.);
	if(val <= 0.) return;
	
	if(filter == 0) gl_FragColor = vec4(1., 0., 0., 1.);
	if(filter == 1) gl_FragColor = vec4(0., 1., 0., 1.);
}