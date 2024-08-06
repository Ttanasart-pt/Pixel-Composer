varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  color;
uniform int   fill;
uniform float thickness;
uniform float antialias;
uniform float radius;

void main() {
	float th = thickness == 0.? 0.05 : thickness;
	float aa = antialias == 0.? 0.05 : antialias;
	float rr = radius == 0.? 0.5 : radius; 
	
	float dist = length(v_vTexcoord - .5) / rr - (1. - th - aa);
	float a;
	
	if(fill == 0) {
		dist = abs(dist);
		a = smoothstep(th + aa, th, dist);
		
	} else if(fill == 1) {
		a = smoothstep(aa, 0., dist);
	}
	
	vec4  c = mix(vec4(0.), color, a);
	
	gl_FragColor = c;
}
