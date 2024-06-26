varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  color;
uniform float index;
uniform int   type;

float line_segment(in vec2 a, in vec2 b) {
	vec2 p = v_vTexcoord;
	
	vec2 ba = b - a;
	vec2 pa = p - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0., 1.);
	return length(pa - h * ba);
}

void main() {
	float dist;
	float a = 0.3 - index * 0.1;
	float b = 1. - a;
	
	dist = min(line_segment(vec2(0.5, a), vec2(0.5, b)), 
			   line_segment(vec2(a, 0.5), vec2(b, 0.5))
		   ) * 3.;
	dist = 1. - dist - 0.5;
	
	vec4  c = vec4(0.);
	
	if(type == 0) { 
		a = smoothstep(.0, .1, dist);
		c = mix(c, vec4(0., 0., 0., 1.), a);      
		
		a = smoothstep(.15, .2, dist);
		c = mix(c, vec4(1., 1., 1., 1.), a);
		
		a = smoothstep(.3, .4, dist);
		c = mix(c, color, a);
		
	} else if(type == 1) { 
		a = smoothstep(.3, .4, dist);
		c = mix(c, color, a);
	}
	
	gl_FragColor = c;
}
