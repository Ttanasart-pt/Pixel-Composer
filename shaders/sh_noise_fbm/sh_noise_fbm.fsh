// Fractal Brownian Motion
// Author @patriciogv - 2015
// http://patriciogonzalezvivo.com

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  position;
uniform float scale;
uniform float seed;
uniform int   iteration;

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

float random (in vec2 st) { return fract(sin(dot(st.xy + mod(seed, 1000.), vec2(1892.9898, 78.23453))) * 437.54123); }

float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

float fbm (in vec2 st) {
	float value = 0.0;
    float amplitude = pow(2., float(iteration) - 1.)  / (pow(2., float(iteration)) - 1.);
    float frequency = 0.;
    
    for (int i = 0; i < iteration; i++) {
        value += amplitude * noise(st);
        st *= 2.;
        amplitude *= .5;
    }
	
    return value;
}

void main() {
	vec2 vtx = useUvMap == 0? v_vTexcoord : mix(v_vTexcoord, texture2D( uvMap, v_vTexcoord ).xy, uvMapMix);
	vec2 pos = position + vtx * scale;
    
	if(colored == 0)
		gl_FragColor = vec4(vec3(fbm(pos)), 1.0);
	else if(colored == 1) {
		float randR = colorRanR[0] + fbm(pos) * (colorRanR[1] - colorRanR[0]);
		float randG = colorRanG[0] + fbm(pos + vec2(1.7227, 4.55529)) * (colorRanG[1] - colorRanG[0]);
		float randB = colorRanB[0] + fbm(pos + vec2(6.9950, 6.82063)) * (colorRanB[1] - colorRanB[0]);
		
		gl_FragColor = vec4(randR, randG, randB, 1.0);
	} else if(colored == 2) {
		float randH = colorRanR[0] + fbm(pos) * (colorRanR[1] - colorRanR[0]);
		float randS = colorRanG[0] + fbm(pos + vec2(1.7227, 4.55529)) * (colorRanG[1] - colorRanG[0]);
		float randV = colorRanB[0] + fbm(pos + vec2(6.9950, 6.82063)) * (colorRanB[1] - colorRanB[0]);
		
		gl_FragColor = vec4(hsv2rgb(vec3(randH, randS, randV)), 1.0);
	}
}