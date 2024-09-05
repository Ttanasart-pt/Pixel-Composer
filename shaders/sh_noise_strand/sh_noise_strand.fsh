#define TAU 6.28318530718

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  u_resolution;
uniform vec2  position;
uniform float density;
uniform float seed;
uniform float slope;
uniform int   axis;
uniform int   mode;
uniform vec2  alpha;

uniform vec2  curve;
uniform float curveDetail;
uniform float curveShift;
uniform float thickness;

float random  (in vec2 st) { return fract(sin(dot(st.xy + vec2(1., 6.), vec2(2., 7.))) * (1. + seed / 100.)); }

void main() {
	vec2 tx  = 1. / u_resolution;
	vec2 ps  = v_vTexcoord + position;
	float w  = 0.;
	
	vec2 dim = axis == 0? u_resolution : u_resolution.yx;
	vec2 pos = axis == 0? ps : ps.yx;
	
	float _t  = min(tx.x, tx.y) / 2.;
	float mt  = 1. - _t;
	float rp  = dim.x;
	int   amo = int(density * rp);
	
    for (int i = 0; i < amo; i++) {
		float _x = random(vec2(float(i), 1.));
		float _y = random(vec2(1., float(i)));
		
		float _s = random(vec2(2., float(i))) - 0.5;
    	float _a = mix(alpha.x, alpha.y, random(vec2(float(i), 2.)));
		
		float _c = mix(curve.x, curve.y, random(vec2(float(i), 3.)));
		
		_x += _s * 2. * (pos.y - _y) * slope;
		_x += sin((pos.y - _y) * curveDetail * dim.y / 4. + (curveShift * TAU/* * sign(_y - 0.5)*/)) * _c / dim.x * 2.;
		
		if(mode == 0) {
			float st = smoothstep(mt - thickness, mt + thickness, 1. - abs(pos.x - _x)) * _a;
			w = max(w, st);
			
		} else if(mode == 1) {
			float st = smoothstep(mt - thickness, mt + thickness, 1. - max(0., pos.x - _x)) * (1. / float(amo));
			w += st;
		}
    }
    
    gl_FragColor = vec4(vec3(w), 1.);
}
