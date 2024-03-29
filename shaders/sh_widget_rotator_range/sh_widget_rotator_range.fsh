#define PI  3.14159265359

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float side;
uniform vec4  color;
uniform vec2  angle;

float line_segment(in float ang) {
	vec2 a = vec2(.5);
	vec2 b = vec2(.5) + vec2(cos(ang), -sin(ang)) * 0.3;
	vec2 p = v_vTexcoord;
	
	vec2 ba = b - a;
	vec2 pa = p - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0., 1.);
	return length(pa - h * ba);
}

void main() {
	float dist   = length(v_vTexcoord - .5) - 0.3;
	float alp    = 0.;
	bool  inside = dist < 0.;
	
	dist = abs(dist);
	alp = max(alp, smoothstep(2. / side, 0.8 / side, dist));
	alp = max(alp, smoothstep(2. / side, 0.8 / side, line_segment(angle[0])));
	alp = max(alp, smoothstep(2. / side, 0.8 / side, line_segment(angle[1])));
	
	gl_FragColor = vec4(color.rgb, alp);
}
