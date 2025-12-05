varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float seed;

uniform int  colored;
uniform vec2 colorRanR;
uniform vec2 colorRanG;
uniform vec2 colorRanB;

uniform sampler2D uvMap;
uniform int   useUvMap;
uniform float uvMapMix;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float random (in vec2 st, float seed) { return fract(sin(dot(st.xy + seed / 1000., vec2(1892.9898, 78.23453))) * 437.54123); }

float frandom (in vec2 st) {
    float n0 = random(st, floor(seed) / 5000.);
	float n1 = random(st, (floor(seed) + 1.) / 5000.);
	return mix(n0, n1, fract(seed));
}

void main() {
	vec2 vtx = useUvMap == 0? v_vTexcoord : mix(v_vTexcoord, texture2D( uvMap, v_vTexcoord ).xy, uvMapMix);
	
	if(colored == 0)
		gl_FragColor = vec4(vec3(frandom(vtx)), 1.0);
		
	else if(colored == 1) {
		float randR = colorRanR[0] + frandom(vtx) * (colorRanR[1] - colorRanR[0]);
		float randG = colorRanG[0] + frandom(vtx + vec2(1.7227, 4.55529)) * (colorRanG[1] - colorRanG[0]);
		float randB = colorRanB[0] + frandom(vtx + vec2(6.9950, 6.82063)) * (colorRanB[1] - colorRanB[0]);
		
		gl_FragColor = vec4(randR, randG, randB, 1.0);
		
	} else if(colored == 2) {
		float randH = colorRanR[0] + frandom(vtx) * (colorRanR[1] - colorRanR[0]);
		float randS = colorRanG[0] + frandom(vtx + vec2(1.7227, 4.55529)) * (colorRanG[1] - colorRanG[0]);
		float randV = colorRanB[0] + frandom(vtx + vec2(6.9950, 6.82063)) * (colorRanB[1] - colorRanB[0]);
		
		gl_FragColor = vec4(hsv2rgb(vec3(randH, randS, randV)), 1.0);
	}
}
