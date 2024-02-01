varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  u_resolution;
uniform vec2  position;
uniform float density;
uniform float seed;
uniform float slope;

uniform float curve;
uniform float curveDetail;
uniform float thickness;

float random  (in vec2 st) { return fract(sin(dot(st.xy + vec2(1., 6.), vec2(2., 7.))) * (1. + seed)); }

void main() {
	vec2 tx  = 1. / u_resolution;
	vec2 pos = v_vTexcoord + position;
	float w  = 0.;
	
	float _t  = min(tx.x, tx.y) / 2.;
	float mt  = 1. - _t;
	float rp  = u_resolution.x;
	int   amo = int(density * rp);
	
    for (int i = 0; i < amo; i++) {
		float _x = random(vec2(float(i), 1.));
		float _y = random(vec2(1., float(i)));
		
		float _s = random(vec2(2., float(i))) - 0.5;
    	float _a = random(vec2(float(i), 2.));
		
		_x += _s * 2. * (pos.y - _y) * slope;
		_x += sin((pos.y - _y) * curveDetail * u_resolution.y / 4.) * curve / u_resolution.x * 2.;
		
		float st = smoothstep(mt - thickness, mt + thickness, 1. - abs(pos.x - _x)) * _a;
		
		w = max(w, st);
    }
    
    gl_FragColor = vec4(vec3(w), 1.);
}
