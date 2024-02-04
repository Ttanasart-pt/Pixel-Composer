#define TAU 6.28318530718

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  u_resolution;
uniform float density;
uniform float seed;
uniform vec2  scale;
uniform vec2  alpha;
uniform int   mode;
uniform int   render;

uniform float thickness;

float random  (in vec2 st) { return fract(sin(dot(st.xy + vec2(1., 6.), vec2(2., 7.))) * (1. + seed / 100.)); }

void main() {
	vec2 tx  = 1. / u_resolution;
	vec2 ps  = v_vTexcoord;
	float w  = 0.;
	
	vec2 dim = u_resolution;
	vec2 pos = ps;
	
	float _t  = min(tx.x, tx.y) / 2.;
	float rp  = dim.x;
	int   amo = int(density * rp);
	
    for (int i = 0; i < amo; i++) {
		float _x = random(vec2(float(i), 1.));
		float _y = random(vec2(1., float(i)));
		
		float _s = mix(scale.x, scale.y, random(vec2(2., float(i))));
    	float _a = mix(alpha.x, alpha.y, random(vec2(float(i), 2.)));
		
		float dst = 1. - distance(pos, vec2(_x, _y));
		float st;
		
		     if(mode == 0) st = smoothstep(1. - max(_t, thickness), 1., 1. - abs(dst - (1. - _s))) * _a;
		else if(mode == 1) st = smoothstep(1. - _s - thickness, 1. - _s + thickness, max(0., dst)) * _a;
		
		     if(render == 0) w  = max(w, st);
		else if(render == 1) w += st;
    }
    
    gl_FragColor = vec4(vec3(w), 1.);
}
