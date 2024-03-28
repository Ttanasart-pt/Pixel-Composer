varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  color;
uniform float index;

void main() {
	float dist  = 1. - length(v_vTexcoord - .5) * 2.;
	      dist -= mix(.2, .0, index);
		  
	float a;
	vec4  c = vec4(0.);
	
	a = smoothstep(.0, .1, dist);
	c = mix(c, vec4(0., 0., 0., 1.), a);      
	
	a = smoothstep(.15, .2, dist);
	c = mix(c, vec4(1., 1., 1., 1.), a);
	
	a = smoothstep(.3, .4, dist);
	c = mix(c, color, a);
	
	gl_FragColor = c;
}
