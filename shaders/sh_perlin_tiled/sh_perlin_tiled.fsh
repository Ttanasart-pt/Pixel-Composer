varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  position;
uniform vec2  dimension;
uniform float rotation;

uniform vec2      scale;
uniform int       scaleUseSurf;
uniform sampler2D scaleSurf;

uniform int   iteration;
uniform float seed;
uniform float phase;
uniform int   tile;

uniform float itrScaling;
uniform float itrAmplitude;

uniform int  colored;
uniform vec2 colorRanR;
uniform vec2 colorRanG;
uniform vec2 colorRanB;

uniform sampler2D uvMap;
uniform int   useUvMap;
uniform float uvMapMix;

vec2 sca;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float random  (in vec2 st) { return smoothstep(0., 1., abs(fract(sin(dot(st.xy + vec2(21.456, 46.856), vec2(12.989, 78.233))) * (43758.545 + seed)) * 2. - 1.)); }
vec2  random2 (in vec2 st) { float a = fract(random(st) + phase) * 6.28319; return vec2(cos(a), sin(a)); }

float noise (in vec2 st, in vec2 scale) {
    vec2 cellMin = floor(st);
    vec2 cellMax = floor(st) + vec2(1., 1.);
	
	if(tile == 1) {
		cellMin = mod(cellMin, scale);
		cellMax = mod(cellMax, scale);
	}
	
	vec2 f = fract(st);
	vec2 u = f * f * (3.0 - 2.0 * f);
	
	vec2 _a = vec2(cellMin.x, cellMin.y);
	vec2 _b = vec2(cellMax.x, cellMin.y);
	vec2 _c = vec2(cellMin.x, cellMax.y);
	vec2 _d = vec2(cellMax.x, cellMax.y);
	
	vec2 ai = f - vec2(0., 0.);
    vec2 bi = f - vec2(1., 0.);
    vec2 ci = f - vec2(0., 1.);
    vec2 di = f - vec2(1., 1.);
	
	vec2 a2 = random2(_a);
    vec2 b2 = random2(_b);
    vec2 c2 = random2(_c);
    vec2 d2 = random2(_d);
	
	float l1 = mix(dot(ai, a2), dot(bi, b2), u.x);
	float l2 = mix(dot(ci, c2), dot(di, d2), u.x);
	
    return mix(l1, l2, u.y) + 0.5;
}

float perlin(in vec2 st) {
	float inAmp = 1. / itrAmplitude;
	float amp = pow(inAmp, float(iteration) - 1.)  / (pow(inAmp, float(iteration)) - 1.);
    float n   = 0.;
	vec2  pos = st;
	vec2  sc  = sca;
	
	for(int i = 0; i < iteration; i++) {
		n += noise(pos, sc) * amp;
		
		sc  *= itrScaling;
		amp *= itrAmplitude;
		pos *= itrScaling;
	}
	
	return n;
}

void main() {
	#region params
		sca = scale;
		if(scaleUseSurf == 1) {
			vec4 _vMap = texture2D( scaleSurf, v_vTexcoord );
			sca = vec2(mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.));
		}
	#endregion
	
	vec2 st;
	vec2 pos = position / dimension;
	vec2 vtx = useUvMap == 0? v_vTexcoord : mix(v_vTexcoord, texture2D( uvMap, v_vTexcoord ).xy, uvMapMix);
	
	if(tile == 1) {
		sca = floor(sca);
		st  = fract(vtx - pos) * sca;
		
	} else {
		st  = (vtx - pos) * mat2(cos(rotation), -sin(rotation), sin(rotation), cos(rotation)) * sca;
	}
	
	if(colored == 0) {
		gl_FragColor = vec4(vec3(perlin(st)), 1.0);
		
	} else if(colored == 1) {
		float randR = colorRanR[0] + perlin(st)                         * (colorRanR[1] - colorRanR[0]);
		float randG = colorRanG[0] + perlin(st + vec2(1.7227, 4.55529)) * (colorRanG[1] - colorRanG[0]);
		float randB = colorRanB[0] + perlin(st + vec2(6.9950, 6.82063)) * (colorRanB[1] - colorRanB[0]);
		
		gl_FragColor = vec4(randR, randG, randB, 1.0);
		
	} else if(colored == 2) {
		float randH = colorRanR[0] + perlin(st)                         * (colorRanR[1] - colorRanR[0]);
		float randS = colorRanG[0] + perlin(st + vec2(1.7227, 4.55529)) * (colorRanG[1] - colorRanG[0]);
		float randV = colorRanB[0] + perlin(st + vec2(6.9950, 6.82063)) * (colorRanB[1] - colorRanB[0]);
		
		gl_FragColor = vec4(hsv2rgb(vec3(randH, randS, randV)), 1.0);
	}
}