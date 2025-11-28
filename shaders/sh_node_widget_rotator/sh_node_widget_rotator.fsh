varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  color;
uniform int   type;
uniform float index;
uniform float angle;

float sdArc( in vec2 p, in float tb, in float ra, float rb ) {
    vec2 sc = vec2(sin(tb), cos(tb));
    p.x = abs(p.x);
	
    return ((sc.y*p.x>sc.x*p.y) ? length(p-sc*ra) : abs(length(p)-ra)) - rb;
}

void main() {
	vec2  p = v_vTexcoord - vec2(.5, .5);
		  p *= mat2(cos(angle), -sin(angle), sin(angle), cos(angle)) * 2.;
		  p += vec2(.0, .7);
	
	float dist = 1. - sdArc(p, mix(.3, .6, index), 1., .0) * 2. - .4;
	float a;
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
		
	} else if(type == 2) { 
		a = smoothstep(.15, .25, dist);
		c = mix(c, color, a);
		
		a = smoothstep(.35, .45, dist);
		c = mix(c, vec4(1., 1., 1., 1.), a);
	} 
	
	gl_FragColor = c;
}
