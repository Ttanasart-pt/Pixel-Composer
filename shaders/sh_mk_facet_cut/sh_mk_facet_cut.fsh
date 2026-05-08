varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D depthSurf;
uniform sampler2D cutSurf;
uniform float angle;
uniform float order;

void main() {
	vec4 dep = texture2D(depthSurf, v_vTexcoord);
	vec4 cut = texture2D(cutSurf,   v_vTexcoord);
	
	gl_FragColor = dep;
	if(cut.a == 0. || dep.a == 0.) return;
	
	if(cut.r < dep.r) {
		gl_FragColor.r = cut.r;
		gl_FragColor.g = angle;
		gl_FragColor.b = order;
	}
	
	
}