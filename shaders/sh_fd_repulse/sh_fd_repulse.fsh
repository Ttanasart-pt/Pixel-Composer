#define TAU 6.283185307179586

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float strength;
uniform vec2  center;
uniform float radius;

uniform float spokes;
uniform float rotate;

void main() {
	vec2  pos   = v_vTexcoord - center;
	float rad   = length(pos);
	float dist  = rad * strength;
	float drad  = smoothstep(radius * strength, 0., dist);
	
	float angle = atan(pos.y, pos.x);
	if(spokes != 0.) {
		float sp = TAU / spokes;
		angle = floor(angle / sp) * sp + sp * .5 + rotate;
	}
	
	gl_FragColor = vec4(cos(angle) * dist * drad, sin(angle) * dist * drad, 0., 1.);
}
