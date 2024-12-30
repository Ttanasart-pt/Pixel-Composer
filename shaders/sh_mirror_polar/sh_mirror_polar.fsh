varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TAU 6.283185307179586
#define PI  3.141592653589793

uniform vec2  dimension;
uniform vec2  position;
uniform float angle;
uniform float spokes;
uniform int   reflecc;

float round(in float a) { return floor(a + .5);  }

void main() {
	vec2  ps = v_vTexcoord;
	vec2  px = v_vTexcoord * dimension - position;
	float _angle;
	float a = TAU / spokes;
	if(reflecc == 1) a *= 2.;
	
	_angle = atan(px.y, px.x) + angle;
	_angle = TAU - mod(_angle, TAU); 
	_angle = mod(_angle, a);
	
	if(reflecc == 1 && _angle > a / 2.) _angle = a - _angle;
	
	if(_angle < PI) {
		float _alpha    = (angle + PI) - (_angle + angle);
		float inv_angle = (angle + PI) + _alpha;
		float dist      = length(px);
		
		ps = (position + vec2(cos(inv_angle) * dist, -sin(inv_angle) * dist )) / dimension;
	} 
	
	ps = fract(ps);
	
	if(mod(floor(ps.x), 2.) > 1.) ps.x = 1. - ps.x;
	if(mod(floor(ps.y), 2.) > 1.) ps.y = 1. - ps.y;
	
	gl_FragColor = texture2D( gm_BaseTexture, ps );
}
