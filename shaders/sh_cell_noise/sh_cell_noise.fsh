varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  position;
uniform float rotation;
uniform int   pattern;
uniform float seed;
uniform float phase;

uniform int   iteration;
uniform float iterScale;
uniform float iterAmpli;
uniform int   blendMode;

uniform vec2      scale;
uniform int       scaleUseSurf;
uniform sampler2D scaleSurf;

uniform float radiusScale;
uniform float radiusShatter;

uniform int   inverted;
uniform float contrast;
uniform float middle;

#define PI 3.14159265359
#define TAU 6.283185307179586

vec2 random2( vec2 p ) { return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453); }

float random(in vec2 st) { return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123); }

float cellNoise(vec2 ntx, vec2 pos, float sca, float scaMax, float ang) {
	vec2  st     = (ntx - pos) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * sca;
	float m_dist = 1.;
	
	if(pattern < 2) {
		vec2 i_st = floor(st);
	    vec2 f_st = fract(st);
		
	    for (int y = -1; y <= 1; y++)
	    for (int x = -1; x <= 1; x++) {
			
	        vec2 neighbor = vec2(float(x),float(y));
	        vec2 point    = random2(pattern == 0? mod(i_st + neighbor, scaMax) : i_st + neighbor);
			
			point = 0.5 + 0.5 * sin(seed + TAU * fract(point + phase));
			
	        vec2 _diff = neighbor + point - f_st;
	        float dist = length(_diff);
	        m_dist = min(m_dist, dist);
	    }
		
	} else if(pattern == 2) {
		
		for (int j = 0; j <= int(sca / 2.); j++) {
			
			int _amo = int(sca) + int(float(j) * radiusShatter);
			for (int i = 0; i <= _amo; i++) {
				
				float angl = ang + TAU / float(_amo) * float(i) + float(j) + random(vec2(0.684, 1.387)) + seed;
				float rad  = pow(float(j) / sca, radiusScale) * sca * .5 + random(vec2(angl)) * 0.1;
				vec2 point = vec2(cos(angl + TAU * phase) * rad, sin(angl + TAU * phase) * rad) + pos;
				
			    vec2 _diff = point - ntx;
			    float dist = length(_diff);
			    m_dist = min(m_dist, dist);
			}
		}
	}
	
	return m_dist;
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
	
	vec2 ntx  = v_vTexcoord * vec2(1., dimension.y / dimension.x);
	vec2 pos  = position / dimension;
	
    float amp = pow(1. / iterAmpli, float(iteration) - 1.) / (pow(1. / iterAmpli, float(iteration)) - 1.);
    float md  = .0;
    
	for(int i = 0; i < iteration; i++) {
		float _noise = cellNoise(ntx, pos, sca, scaMax, ang);
		
		     if(blendMode == 0) md += _noise * amp;
		else if(blendMode == 1) md  = max(md, _noise);
		
		amp *= iterAmpli;
		pos *= iterScale;
	}
	
	float c = middle + (md - middle) * contrast;
	if(inverted == 1) c = 1. - c;
	
    gl_FragColor = vec4(c, c, c, 1.0);
}
