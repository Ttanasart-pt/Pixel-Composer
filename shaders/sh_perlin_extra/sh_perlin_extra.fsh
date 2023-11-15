//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int  type;

uniform vec2  position;
uniform vec2  u_resolution;
uniform vec2  scale;
uniform int   iteration;
uniform float seed;
uniform int   tile;

uniform int  colored;
uniform vec2 colorRanR;
uniform vec2 colorRanG;
uniform vec2 colorRanB;

vec3 hsv2rgb(vec3 c) { #region
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
} #endregion

float random (in vec2 st, float seed) { return fract(sin(dot(st.xy + vec2(21.4564, 46.8564), vec2(12.9898, 78.233))) * (43758.5453123 + seed)); }
float randomFloat (in vec2 st, float seed) { #region
	float sedSt = floor(seed);
	float sedFr = fract(seed);
	//sedFr = sedFr * sedFr * (3.0 - 2.0 * sedFr);
	
	return mix(random(st, sedSt), random(st, sedSt + 1.), sedFr);
} #endregion

vec2 random2 (in vec2 st, float seed) { return vec2(randomFloat(st, seed), randomFloat(st, seed + 1.864354564)); }

float noise (in vec2 st, in vec2 scale) { #region
    vec2 cellMin = floor(st);
    vec2 cellMax = floor(st) + vec2(1., 1.);
	
	if(tile == 1) {
		cellMin = mod(cellMin, scale);
		cellMax = mod(cellMax, scale);
	}
	
	vec2 f = fract(st);
	vec2 u = f * f * (3.0 - 2.0 * f);
	
	float a = 0., b = 0., c = 0., d = 0.;
	
	if(type == 0) {
	    a = dot( random2(vec2(cellMin.x, cellMin.y) * 2. - 1., seed), f - vec2(0., 0.) );
	    b = dot( random2(vec2(cellMax.x, cellMin.y) * 2. - 1., seed), f - vec2(1., 0.) );
	    c = dot( random2(vec2(cellMin.x, cellMax.y) * 2. - 1., seed), f - vec2(0., 1.) );
	    d = dot( random2(vec2(cellMax.x, cellMax.y) * 2. - 1., seed), f - vec2(1., 1.) );
		
		return abs(mix(mix(a, b, u.x), mix(c, d, u.x), u.y));
	} else if(type == 1 || type == 2 || type == 3) {
	    a = randomFloat(vec2(cellMin.x, cellMin.y), seed);
	    b = randomFloat(vec2(cellMax.x, cellMin.y), seed);
	    c = randomFloat(vec2(cellMin.x, cellMax.y), seed);
	    d = randomFloat(vec2(cellMax.x, cellMax.y), seed);
		
		float _m = mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
		
		return _m;
	}
	
	return 0.;
} #endregion

float perlin(in vec2 st) { #region
	float amp = pow(2., float(iteration) - 1.)  / (pow(2., float(iteration)) - 1.);
	if(type == 0) amp = pow(2., float(iteration) + 1.)  / (pow(2., float(iteration)) - 1.);
	if(type == 3) amp *= 1.25;
	
    float n  = 0., m = 0.;
	vec2 pos = st;
	vec2  sc = scale;
	float it = float(iteration);
	
	if(type == 3) it *= 3.;
	
	for(float i = 0.; i < it; i++) {
		float _n = noise(pos, sc);
		
		if(type == 3) {
			m += _n * amp;
			if(mod(i, 3.) == 2.) {
				n += smoothstep(0.4, 0.6, m) * amp;
				m = 0.;
				
				sc  /= 1.5;
				amp /= .75;
				pos /= 1.5;
			} else {
				sc  *= 1.5;
				amp *= .75;
				pos *= 1.5;
			}
		} else 
			n += _n * amp;
		
		pos += random2(vec2(float(i)), 0.574186) * sc;
		
		if(type == 0) {
			sc  *= 2.;
			amp *= .5;
			pos *= 2.;
		} else if(type == 1) {
			sc  *= 2.;
			amp *= .5;
			pos *= 1. + _n;
		} else if(type == 2) {
			sc  *= 2.;
			amp *= .5;
			pos += random2(vec2(n), seed) / sc;
			pos *= 2.;
		}
	}
	
	return n;
} #endregion

void main() { #region
	if(colored == 0) {
		vec2 pos = (v_vTexcoord + position) * scale;
		gl_FragColor = vec4(vec3(perlin(pos)), 1.0);
	} else if(colored == 1) {
		float randR = colorRanR[0] + perlin((v_vTexcoord + position) * scale) * (colorRanR[1] - colorRanR[0]);
		float randG = colorRanG[0] + perlin((v_vTexcoord + position + vec2(1.7227, 4.55529)) * scale) * (colorRanG[1] - colorRanG[0]);
		float randB = colorRanB[0] + perlin((v_vTexcoord + position + vec2(6.9950, 6.82063)) * scale) * (colorRanB[1] - colorRanB[0]);
		
		gl_FragColor = vec4(randR, randG, randB, 1.0);
	} else if(colored == 2) {
		float randH = colorRanR[0] + perlin((v_vTexcoord + position) * scale) * (colorRanR[1] - colorRanR[0]);
		float randS = colorRanG[0] + perlin((v_vTexcoord + position + vec2(1.7227, 4.55529)) * scale) * (colorRanG[1] - colorRanG[0]);
		float randV = colorRanB[0] + perlin((v_vTexcoord + position + vec2(6.9950, 6.82063)) * scale) * (colorRanB[1] - colorRanB[0]);
		
		gl_FragColor = vec4(hsv2rgb(vec3(randH, randS, randV)), 1.0);
	}
} #endregion