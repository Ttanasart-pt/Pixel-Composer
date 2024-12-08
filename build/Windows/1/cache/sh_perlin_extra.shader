//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
#define TAU 6.28318530718

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int  type;
uniform vec2 dimension;

uniform vec2  position;
uniform float rotation;
uniform int   iteration;
uniform float seed;
uniform int   tile;

uniform vec2      scale;
uniform int       scaleUseSurf;
uniform sampler2D scaleSurf;
		vec2      sca;

uniform vec2      paramA;
uniform int       paramAUseSurf;
uniform sampler2D paramASurf;
		float     A;

uniform vec2      paramB;
uniform int       paramBUseSurf;
uniform sampler2D paramBSurf;
        float     B;

uniform int  colored;
uniform vec2 colorRanR;
uniform vec2 colorRanG;
uniform vec2 colorRanB;

vec3 hsv2rgb(vec3 c) { 
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
} 

float random (in vec2 st, float seed) { return fract(sin(dot(st.xy + vec2(21.4564, 46.8564), vec2(12.9898, 78.233))) * (43758.5453123 + seed)); }
float randomFloat (in vec2 st, float seed) { 
	float sedSt = floor(seed);
	float sedFr = fract(seed);
	//sedFr = sedFr * sedFr * (3.0 - 2.0 * sedFr);
	
	return mix(random(st, sedSt), random(st, sedSt + 1.), sedFr);
} 

float smooth(in float n, in float itr) { 
	float _fr  = fract(itr);
	float _itr = floor(itr);
	
	for(float i = 0.; i < _itr; i++)
		n = n * n * (3.0 - 2.0 * n);
	float _n1 = n * n * (3.0 - 2.0 * n);
	return mix(n, _n1, _fr);
} 

vec2 random2 (in vec2 st, float seed) { return vec2(randomFloat(st, seed), randomFloat(st, seed + 1.864354564)); }

float noise (in vec2 st, in vec2 scale) { 
    vec2 cellMin = floor(st);
    vec2 cellMax = floor(st) + vec2(1., 1.);
	
	if(tile == 1) {
		cellMin = mod(cellMin, scale);
		cellMax = mod(cellMax, scale);
	}
	
	vec2 f = fract(st);
	vec2 u = f * f * (3.0 - 2.0 * f);
	if(type == 4) {
		u.x = smooth(f.x, 2. + A * 4.);
		u.y = smooth(f.y, 2. + A * 4.);
	}
	
	float a = 0., b = 0., c = 0., d = 0.;
	
	if(type == 0) {
	    a = dot( random2(vec2(cellMin.x, cellMin.y) * 2. - 1., seed), f - vec2(0., 0.) );
	    b = dot( random2(vec2(cellMax.x, cellMin.y) * 2. - 1., seed), f - vec2(1., 0.) );
	    c = dot( random2(vec2(cellMin.x, cellMax.y) * 2. - 1., seed), f - vec2(0., 1.) );
	    d = dot( random2(vec2(cellMax.x, cellMax.y) * 2. - 1., seed), f - vec2(1., 1.) );
		
		return abs(mix(mix(a, b, u.x), mix(c, d, u.x), u.y));
	} else {
	    a = randomFloat(vec2(cellMin.x, cellMin.y), seed);
	    b = randomFloat(vec2(cellMax.x, cellMin.y), seed);
	    c = randomFloat(vec2(cellMin.x, cellMax.y), seed);
	    d = randomFloat(vec2(cellMax.x, cellMax.y), seed);
		
		float _m = mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
		
		return _m;
	}
	
	return 0.;
} 

float _perlin(in vec2 st) { 
	float amp = pow(2., float(iteration) - 1.)  / (pow(2., float(iteration)) - 1.);
	if(type == 0) amp = pow(2., float(iteration) + 1.)  / (pow(2., float(iteration)) - 1.);
	if(type == 3) amp *= 1.25;
	
    float n  = 0., m = 0.;
	vec2 pos = st;
	vec2  sc = sca;
	float it = float(iteration);
	
	if(type == 3) it *= 3.;
	
	for(float i = 0.; i < it; i++) {
		float _n = noise(pos, sc);
		
		if(type == 3) {
			m += _n * amp;
			if(mod(i, 3.) == 2.) {
				n += smoothstep(0.5 - A, 0.5 + A, m) * amp;
				m = 0.;
				
				sc  /= 1.5;
				amp /= .75;
				pos /= 1.5;
			} else {
				sc  *= 1.5;
				amp *= .75;
				pos *= 1.5;
			}
		} else if(type == 4) {
			n += smooth(_n, 1. + A * 5. * i / it) * amp;
		} else if(type == 5) {
			n = max(n, _n);
			sc  *= 1. + A * 0.1;
			pos *= 1. + A * 0.1;
		} else 
			n += _n * amp;
		
		pos += random2(vec2(float(i)), 0.574186) * sc;
		
		if(type == 1) {
			sc  *= 2.;
			amp *= .5;
			pos *= 1. + _n + A;
		} else if(type == 2) {
			sc  *= 2.;
			amp *= .5;
			pos += random2(vec2(n), seed) / sc;
			pos *= (2. + A);
		} else if(type == 3) {
		} else if(type == 5) {
		} else {
			sc  *= 2.;
			amp *= .5;
			pos *= 2.;
		}
		
	}
	
	return n;
} 

float perlin(in vec2 st) { 
	if(type == 6) {
		float p1 = _perlin(st - vec2( 1.,  0.) / sca * (1. + A));
	    float p2 = _perlin(st - vec2( 0.,  1.) / sca * (1. + A));
	    float p3 = _perlin(st - vec2(-1.,  0.) / sca * (1. + A));
	    float p4 = _perlin(st - vec2( 0., -1.) / sca * (1. + A));
		return abs(p1 - p3) + abs(p2 - p4);
	}
	
	return _perlin(st);
} 

void main() { 
	
		sca = scale;
		if(scaleUseSurf == 1) {
			vec4 _vMap = texture2D( scaleSurf, v_vTexcoord );
			sca = vec2(mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.));
		}
		
		A = paramA.x;
		if(paramAUseSurf == 1) {
			vec4 _vMap = texture2D( paramASurf, v_vTexcoord );
			A = mix(paramA.x, paramA.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		B = paramB.x;
		if(paramBUseSurf == 1) {
			vec4 _vMap = texture2D( paramBSurf, v_vTexcoord );
			B = mix(paramB.x, paramB.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	
	
	vec2  ntx = v_vTexcoord * vec2(1., dimension.y / dimension.x);
	float ang = radians(rotation);
    vec2  uv  = (ntx - position / dimension) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * sca;
    
	if(colored == 0) {
		gl_FragColor = vec4(vec3(perlin(uv)), 1.0);
		
	} else if(colored == 1) {
		float randR = colorRanR[0] + perlin(uv                        ) * (colorRanR[1] - colorRanR[0]);
		float randG = colorRanG[0] + perlin(uv + vec2(1.7227, 4.55529)) * (colorRanG[1] - colorRanG[0]);
		float randB = colorRanB[0] + perlin(uv + vec2(6.9950, 6.82063)) * (colorRanB[1] - colorRanB[0]);
		
		gl_FragColor = vec4(randR, randG, randB, 1.0);
		
	} else if(colored == 2) {
		float randH = colorRanR[0] + perlin(uv                        ) * (colorRanR[1] - colorRanR[0]);
		float randS = colorRanG[0] + perlin(uv + vec2(1.7227, 4.55529)) * (colorRanG[1] - colorRanG[0]);
		float randV = colorRanB[0] + perlin(uv + vec2(6.9950, 6.82063)) * (colorRanB[1] - colorRanB[0]);
		
		gl_FragColor = vec4(hsv2rgb(vec3(randH, randS, randV)), 1.0);
	}
} 

