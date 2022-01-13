//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform sampler2D fore;
uniform vec2 position;
uniform vec2 scale;
uniform float rotation;

void main() {
	vec4 _col1 = texture2D( gm_BaseTexture, v_vTexcoord );
	vec2 center = vec2(.5, .5);
	vec2 pos = (((v_vTexcoord - position) / dimension) - center) / scale + center;
	vec2 delta = pos - center;
	
	pos.x = center.x + delta.x * cos(rotation) - delta.y * sin(rotation);
	pos.y = center.y + delta.x * sin(rotation) + delta.y * cos(rotation);
	
	if(pos.x >= 0. && pos.x <= 1. && pos.y >= 0. && pos.y <= 1.) {
		vec4 _col0 = texture2D( fore, pos);
		
		float al = _col0.a + _col1.a * (1. - _col0.a);
		vec4 res = ((_col0 * _col0.a) + (_col1 * _col1.a * (1. - _col0.a))) / al;
		res.a = al;
	
	    gl_FragColor = res;
	} else {
		gl_FragColor = _col1;
	}	
}
