varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  color;
uniform int   fill;
uniform float thickness;
uniform float antialias;
uniform float radius;
uniform vec2  arcRad;

#define TAU 6.28318530718

bool angleIn(float a, float f, float t) {
	float e = (t - f) < 0. ? t - f + TAU : t - f;    
    float m = (a - f) < 0. ? a - f + TAU : a - f; 
    return m < e; 
}

void main() {
	float ang = atan(-(v_vTexcoord.y - 0.5), v_vTexcoord.x - 0.5);
	float th  = thickness == 0.? 0.05 : thickness;
	float aa  = antialias == 0.? 0.05 : antialias;
	float rr  = radius == 0.? 0.5 : radius; 
	
	float dist = length(v_vTexcoord - .5) / rr - (1. - th - aa);
	float a;
	
	if(fill == 0) {
		dist = abs(dist);
		a = smoothstep(th + aa, th, dist);
		
	} else if(fill == 1) {
		a = smoothstep(aa, 0., dist);
	}
	
	gl_FragColor = vec4(0.);
	if(angleIn(ang, arcRad.x, arcRad.y))
		gl_FragColor = vec4(color.rgb, color.a * a);
	
}
