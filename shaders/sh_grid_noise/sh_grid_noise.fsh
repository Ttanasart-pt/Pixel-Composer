//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  position;
uniform vec2  scale;
uniform float seed;
uniform float shift;
uniform int shiftAxis;
uniform int useSampler;

uniform int colored;
uniform vec2 colorRanR;
uniform vec2 colorRanG;
uniform vec2 colorRanB;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float randomSeed (in vec2 st, float _seed) { return fract(sin(dot(st.xy + vec2(5.0654, 9.684), vec2(12.9898, 78.233))) * (43758.5453123 + _seed)); }

float random (in vec2 st) { return mix(randomSeed(st, floor(seed)), randomSeed(st, floor(seed) + 1.), fract(seed)); }

void main() {
	vec2 st = v_vTexcoord - position / dimension;
    vec2 pos = vec2(st * scale);
	
	if(shiftAxis == 0) {
		//pos.x += random(vec2(0., floor(pos.y)));
		if(mod(pos.y, 2.) > 1.)
			pos.x += shift;
	} else if(shiftAxis == 1) {
		//pos.y += random(vec2(0., floor(pos.x)));
		if(mod(pos.x, 2.) > 1.)
			pos.y += shift;
	}
	
	if(useSampler == 0) {
		vec2 n = floor(pos);
		
		if(colored == 0) {
			gl_FragColor = vec4(vec3(random(n)), 1.0);
		} else if(colored == 1) {
			float randR = colorRanR[0] + random(n) * (colorRanR[1] - colorRanR[0]);
			float randG = colorRanG[0] + random(n + vec2(1.7227, 4.55529)) * (colorRanG[1] - colorRanG[0]);
			float randB = colorRanB[0] + random(n + vec2(6.9950, 6.82063)) * (colorRanB[1] - colorRanB[0]);
		
			gl_FragColor = vec4(randR, randG, randB, 1.0);
		} else if(colored == 2) {
			float randH = colorRanR[0] + random(n) * (colorRanR[1] - colorRanR[0]);
			float randS = colorRanG[0] + random(n + vec2(1.7227, 4.55529)) * (colorRanG[1] - colorRanG[0]);
			float randV = colorRanB[0] + random(n + vec2(6.9950, 6.82063)) * (colorRanB[1] - colorRanB[0]);
		
			gl_FragColor = vec4(hsv2rgb(vec3(randH, randS, randV)), 1.0);
		} 
	} else {
		vec2 samPos = floor(pos) / scale + 0.5 / scale;
		gl_FragColor = texture2D( gm_BaseTexture, samPos );
	}
}
