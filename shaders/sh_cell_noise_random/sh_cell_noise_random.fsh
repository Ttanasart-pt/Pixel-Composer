varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  position;
uniform float seed;
uniform float phase;

uniform int   iteration;
uniform float iterScale;
uniform float iterAmpli;
uniform int   blendMode;

uniform float radiusScale;
uniform float radiusShatter;
uniform int   pattern;
uniform int   colored;
uniform float rotation;
uniform int   tiled;

uniform vec2      scale;
uniform int       scaleUseSurf;
uniform sampler2D scaleSurf;

uniform int   inverted;
uniform float contrast;
uniform float middle;

#define TAU 6.283185307179586

vec2 random2( vec2 p ) { return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453); }

float random (in vec2 st) { return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123); }

vec3 colorNoise(in vec2 st) {
	float randR = random(st);
	float randG = random(st + vec2(1.7227, 4.55529));
	float randB = random(st + vec2(6.9950, 6.82063));
		
	return vec3(randR, randG, randB);
}

vec2 cellNoise(vec2 ntx, vec2 pos, float sca, float scaMax, float ang) {
	vec2 st   = (ntx - pos) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * sca;
    vec2 i_st = floor(st);
    vec2 f_st = fract(st);

    float m_dist = 1.;
	vec2  mp;
	
	if(pattern < 2) {
	    for (int y = -1; y <= 1; y++) {
	        for (int x = -1; x <= 1; x++) {
	            vec2 neighbor = vec2(float(x), float(y));
	            vec2 point    = random2(pattern == 0? mod(i_st + neighbor, scaMax) : i_st + neighbor);
				vec2 pointSam = 0.5 + 0.5 * sin(seed + TAU * (point + phase));
			
	            vec2 _diff = neighbor + pointSam - f_st;
	            float dist = length(_diff);
				
				if(dist < m_dist) {
					m_dist = dist;
					mp     = point;
				}
	        }
	    }
	} else if(pattern == 2) {
		for (int j = 0; j <= int(sca / 2.); j++) {
			int _amo = int(sca) + int(float(j) * radiusShatter);
			for (int i = 0; i <= _amo; i++) {
				float ang  = TAU / float(_amo) * float(i) + float(j) + random(vec2(0.684, 1.387)) + seed;
				float rad  = pow(float(j) / sca, radiusScale) * sca * .5 + random(vec2(ang)) * 0.1;
				vec2 point = vec2(cos(ang + TAU * phase) * rad, sin(ang + TAU * phase) * rad) + pos;
				
			    vec2 _diff = point - ntx;
			    float dist = length(_diff);
			    
				if(dist < m_dist) {
					m_dist = dist;
					mp = point;
				}
			}
		}
	}

	return mp;
}

void main() {
	#region params
		float sca    = scale.x;
		float scaMax = max(scale.x, scale.y);
		if(scaleUseSurf == 1) {
			vec4 _vMap = texture2D( scaleSurf, v_vTexcoord );
			sca = mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float ang = rotation;
	#endregion
	
	vec2 ntx = v_vTexcoord * vec2(1., dimension.y / dimension.x);
	vec2 pos = position / dimension;
	
	float amp = pow(1. / iterAmpli, float(iteration) - 1.) / (pow(1. / iterAmpli, float(iteration)) - 1.);
    vec3  md  = vec3(.0);
    
	for(int i = 0; i < iteration; i++) {
		vec2 _f = cellNoise(ntx, pos, sca, scaMax, ang);
		vec3 _noise;
		
		if(colored == 0) {
			float c = middle + (random(_f + 1.) - middle) * contrast;
		    if(inverted == 1) c = 1. - c;
			
		    _noise = vec3(c) * amp;
		    
		} else if(colored == 1)
			_noise = colorNoise(_f) * amp;
		
		     if(blendMode == 0) md += _noise * amp;
		else if(blendMode == 1) md  = max(md, _noise);
		
		amp *= iterAmpli;
		pos *= iterScale;
	}
	
	gl_FragColor = vec4(md, 1.0);
}
