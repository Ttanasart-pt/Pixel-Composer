//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 position;
uniform float scale;
uniform int pattern;
uniform float time;

uniform float contrast;
uniform float middle;

uniform float radiusScale;
uniform float radiusShatter;

#define PI 3.14159265359
#define TAU 6.28318

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

float random (in vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
	vec2 pos = position / dimension;
    vec2 st = v_vTexcoord - pos;
    vec3 color = vec3(.0);

    st *= scale;

    float m_dist = 1.;
	
	if(pattern == 0) {
		vec2 i_st = floor(st);
	    vec2 f_st = fract(st);
	
	    for (int y = -1; y <= 1; y++) {
	        for (int x = -1; x <= 1; x++) {
	            vec2 neighbor = vec2(float(x),float(y));
	            vec2 point = random2(i_st + neighbor);
				point = 0.5 + 0.5 * sin(time + 6.2831 * point);
			
	            vec2 _diff = neighbor + point - f_st;
	            float dist = length(_diff);
	            m_dist = min(m_dist, dist);
	        }
	    }
	} else if(pattern == 1) {
		for (int j = 0; j <= int(scale / 2.); j++) {
			int _amo = int(scale) + int(float(j) * radiusShatter);
			for (int i = 0; i <= _amo; i++) {
				float ang = TAU / float(_amo) * float(i) + float(j) + time;
				float rad = pow(float(j) / scale, radiusScale) * scale * .5 + random(vec2(ang)) * 0.1;
				vec2 point = vec2(cos(ang) * rad, sin(ang) * rad) + pos;
				
			    vec2 _diff = point - v_vTexcoord;
			    float dist = length(_diff);
			    m_dist = min(m_dist, dist);
			}
		}
	}
	
    color += m_dist;
	
	vec3 c = middle + (color - middle) * contrast;
    gl_FragColor = vec4(c, 1.0);
}
