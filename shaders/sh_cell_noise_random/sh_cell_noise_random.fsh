//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 position;
uniform float scale;
uniform float time;

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

float random (in vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
    vec2 st = v_vTexcoord + position;
    vec3 color = vec3(.0);
    st *= scale;

    vec2 i_st = floor(st);
    vec2 f_st = fract(st);

    float m_dist = 1.;
	vec2 mp;

    for (int y= -1; y <= 1; y++) {
        for (int x= -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x),float(y));
            vec2 point = random2(i_st + neighbor);
			point = 0.5 + 0.5 * sin(time + 6.2831 * point);
			
            vec2 _diff = neighbor + point - f_st;
			
            float dist = length(_diff);
			
			if(dist < m_dist) {
				m_dist = dist;
				mp = point;
			}
        }
    }

    gl_FragColor = vec4(vec3(random(mp)),1.0);
}
