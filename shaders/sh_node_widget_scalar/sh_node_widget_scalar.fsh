varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  color;
uniform float index;
uniform int   type;

void main() {
	float dist  = 1. - length(v_vTexcoord - .5) * 2.;
	      dist -= mix(.2, .0, index);
		  
	float a;
	vec4  c = vec4(0.);
	
	if(type == 0) { 
		a = smoothstep(.0, .1, dist);
		c = mix(c, vec4(0., 0., 0., 1.), a);      
		
		a = smoothstep(.15, .3, dist);
		c = mix(c, vec4(1., 1., 1., 1.), a);
		
		a = smoothstep(.4, .5, dist);
		c = mix(c, color, a);
		
	} else if(type == 1) { 
		a = smoothstep(.3, .4, dist);
		c = mix(c, color, a);
		
	} else if(type == 2) { 
		a = smoothstep(.0, .15, dist);
		c = mix(c, color, a);      
		
		a = smoothstep(.25, .35, dist);
		c = mix(c, vec4(1., 1., 1., 1.), a);
	} 
	
	gl_FragColor = c;
}
