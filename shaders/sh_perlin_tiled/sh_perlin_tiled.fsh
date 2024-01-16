varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  position;
uniform vec2  u_resolution;

uniform vec2      scale;
uniform int       scaleUseSurf;
uniform sampler2D scaleSurf;

uniform int   iteration;
uniform float seed;
uniform int   tile;

uniform int  colored;
uniform vec2 colorRanR;
uniform vec2 colorRanG;
uniform vec2 colorRanB;

vec2 sca;

vec3 hsv2rgb(vec3 c) { #region
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
} #endregion

float random (in vec2 st, float _seed) { return fract(sin(dot(st.xy + vec2(21.456, 46.856), vec2(12.989, 78.233))) * (43758.545 + _seed)); }

float randomFloat (in vec2 st, float _seed) { #region
	float sedSt = floor(_seed);
	float sedFr = fract(_seed);
	
	return mix(random(st, sedSt), random(st, sedSt + 1.), sedFr);
} #endregion

vec2 random2 (in vec2 st, float _seed) { return vec2(random(st, _seed), random(st, _seed + 1.864)); }

float noise (in vec2 st, in vec2 scale) { #region
    vec2 cellMin = floor(st);
    vec2 cellMax = floor(st) + vec2(1., 1.);
	
	if(tile == 1) {
		cellMin = mod(cellMin, scale);
		cellMax = mod(cellMax, scale);
	}
	
	vec2 f = fract(st);
	vec2 u = f * f * (3.0 - 2.0 * f);
	
	float a = randomFloat(vec2(cellMin.x, cellMin.y), seed);
    float b = randomFloat(vec2(cellMax.x, cellMin.y), seed);
    float c = randomFloat(vec2(cellMin.x, cellMax.y), seed);
    float d = randomFloat(vec2(cellMax.x, cellMax.y), seed);
	
    return abs(mix(mix(a, b, u.x), mix(c, d, u.x), u.y));
} #endregion

float perlin(in vec2 st) { #region
	float amp = pow(2., float(iteration) - 1.)  / (pow(2., float(iteration)) - 1.);
    float n   = 0.;
	vec2 pos  = st;
	vec2  sc  = sca;
	
	for(int i = 0; i < iteration; i++) {
		n += noise(pos, sc) * amp;
		
		//pos += random2(vec2(float(i), float(i)), seed + 1.57) * sc; //make the result goes random somehow
		
		sc  *= 2.;
		amp *= .5;
		pos *= 2.;
	}
	
	return n;
} #endregion

void main() { #region
	#region params
		sca = scale;
		if(scaleUseSurf == 1) {
			vec4 _vMap = texture2D( scaleSurf, v_vTexcoord );
			sca = vec2(mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.));
		}
	#endregion
	
	if(colored == 0) {
		vec2 pos = (v_vTexcoord + position) * sca;
		gl_FragColor = vec4(vec3(perlin(pos)), 1.0);
	} else if(colored == 1) {
		float randR = colorRanR[0] + perlin((v_vTexcoord + position) * sca) * (colorRanR[1] - colorRanR[0]);
		float randG = colorRanG[0] + perlin((v_vTexcoord + position + vec2(1.7227, 4.55529)) * sca) * (colorRanG[1] - colorRanG[0]);
		float randB = colorRanB[0] + perlin((v_vTexcoord + position + vec2(6.9950, 6.82063)) * sca) * (colorRanB[1] - colorRanB[0]);
		
		gl_FragColor = vec4(randR, randG, randB, 1.0);
	} else if(colored == 2) {
		float randH = colorRanR[0] + perlin((v_vTexcoord + position) * sca) * (colorRanR[1] - colorRanR[0]);
		float randS = colorRanG[0] + perlin((v_vTexcoord + position + vec2(1.7227, 4.55529)) * sca) * (colorRanG[1] - colorRanG[0]);
		float randV = colorRanB[0] + perlin((v_vTexcoord + position + vec2(6.9950, 6.82063)) * sca) * (colorRanB[1] - colorRanB[0]);
		
		gl_FragColor = vec4(hsv2rgb(vec3(randH, randS, randV)), 1.0);
	}
} #endregion