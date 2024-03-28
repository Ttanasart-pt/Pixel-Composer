varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  color;
uniform float index;
uniform float angle;

float sdArc( in vec2 p, in float tb, in float ra, float rb ) {
    vec2 sc = vec2(sin(tb), cos(tb));
    p.x = abs(p.x);
	
    return ((sc.y*p.x>sc.x*p.y) ? length(p-sc*ra) : 
                                  abs(length(p)-ra)) - rb;
}

void main() {
	vec2  p = v_vTexcoord - .5;
		  p *= mat2(cos(angle), -sin(angle), sin(angle), cos(angle)) * 2.;
	
	float dist = 1. - sdArc(p, .7 + index * .5, .5, .0) * 2. - 0.4;
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
