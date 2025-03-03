varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  c0, c1;
uniform float angle;
uniform vec2  mouse;
uniform float mouseProg;
uniform vec2  radius;

#define TAU 6.28318530718

float angleDiff(float angle1, float angle2) { float dif = mod(angle1 - angle2, TAU); return min(dif, TAU - dif); }

bool angleIn(float a, float f, float t) {
	float e = (t - f) < 0. ? t - f + TAU : t - f;    
    float m = (a - f) < 0. ? a - f + TAU : a - f; 
    return m < e; 
}

float getRad(float ang, out float d1) {
	float dif = angleDiff(ang, angle) / TAU;
	float d0  = smoothstep(0.925, 1.00, 1. - dif);
	      d1  = clamp(1. - smoothstep(0.85 + mouseProg * 0.05, 1.00, 1. - dif) * 2., 0., 0.75);
	      
	float thickness = 0.065;
	if(!angleIn(ang, radius.x, radius.y)) {
		float d0 = angleDiff(ang, radius.x) * 5.;
		float d1 = angleDiff(ang, radius.y) * 5.;
		float da = min(abs(d0), abs(d1));
		
		thickness *= clamp(sqrt(1. - da), 0., 1.);
	}
	
	float rad = (1. - thickness) - d0 * (mouseProg * 0.1 + 0.05);
	return rad;
}

void main() {
	float d1;
	float ang = atan(-(v_vTexcoord.y - 0.5), v_vTexcoord.x - 0.5);
	float rad = getRad(ang, d1);
	
	float dist = distance(v_vTexcoord, vec2(.5)) * 2.;
	float muse = max(0., 0.5 - distance(v_vTexcoord, mouse));
	float ring = dist - muse * 0.2;
	
	ring = 1. - abs(ring - 0.7);
	ring = smoothstep(rad, 1.0, ring) * 25.;
	
	gl_FragColor = vec4(mix(c0.rgb, c1.rgb, d1), ring);
		
}
