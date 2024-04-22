varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  color;
uniform float angle;
uniform vec2  amount;

float sdArc( in vec2 p, in float tb, in float ra, float rb ) {
    vec2 sc = vec2(sin(tb), cos(tb));
    p.x = abs(p.x);
	
    return ((sc.y*p.x>sc.x*p.y) ? length(p-sc*ra) : 
                                  abs(length(p)-ra)) - rb;
}

void main() {
	vec2  p = v_vTexcoord - .5;
	      p *= mat2(cos(angle), -sin(angle), sin(angle), cos(angle)) * 1.5;
	
	float dist = 1. - sdArc(p, .6, .5, 0.) * 2. - 0.4;
	float a;
	vec4  c = vec4(0.);
	
	a = smoothstep(amount.x, amount.y, dist);
	c = mix(c, color, a);
	
	gl_FragColor = c;
}
