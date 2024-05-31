varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  color;
uniform float thickness;
uniform float antialias;

void main() {
	float dist  = abs(length(v_vTexcoord - .5) * 2. - 0.9);
		  
	float a;
	vec4  c  = vec4(0.);
	float th = thickness == 0.? 0.05 : thickness;
	float aa = antialias == 0.? 0.05 : antialias;
	
	a = smoothstep(th + antialias, th, dist);
	c = mix(c, color, a);
	
	gl_FragColor = c;
}
