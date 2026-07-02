varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float seed;

uniform vec2  dimension;
uniform float scale;
uniform vec2  offset;
uniform vec2  level;

uniform float randomness;

#define PI 3.14159265359
#define TAU 6.283185307179586

vec2 random2( in vec2 st ) { return fract(sin(vec2(dot(st, vec2(127.1, 311.7 + seed / 10000.)), 
                                                   dot(st, vec2(269.5 + seed / 10000., 183.3)))) * 43758.5453); }

void main() {
	vec2 tx = 1. / dimension;
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	
	vec2 st   = v_vTexcoord * scale - offset;
	vec2 i_st = floor(st);
    vec2 f_st = fract(st);
    vec2 cell;
    
	float m_dist = 2.;
	
    for (int y = -1; y <= 1; y++)
    for (int x = -1; x <= 1; x++) {
        vec2 neighbor = vec2(float(x),float(y));
        
        vec2 point = .5 + .5 * sin(TAU * fract(random2(i_st + neighbor))) * randomness;
		
        vec2 _diff = neighbor + point - f_st;
        float dist = length(_diff);
        
        if(dist < m_dist) {
        	m_dist = dist;
        	cell   = neighbor + point;
        }
    }
    
    float drip = clamp(1. - m_dist, 0., 1.);
	      drip = mix(level.x, level.y, drip);
	
	gl_FragColor = vec4(drip, cell, base.a);
}