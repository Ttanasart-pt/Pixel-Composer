varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 foreDimension;
uniform vec2 position;
uniform vec4 color;

uniform sampler2D fore;
uniform sampler2D mask;

void main() {
	vec4 _cBg    = texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor = _cBg;
	
	vec2 foreCoord  = v_vTexcoord;
	     foreCoord -= position / dimension;
	     foreCoord /= foreDimension / dimension;
	     
	if(foreCoord.x < 0. || foreCoord.y < 0. || foreCoord.x > 1. || foreCoord.y > 1.) {
		gl_FragColor = color;
		return;
	}
	
	vec4 _maskC  = texture2D( mask, foreCoord );
	if(_maskC.a == 0.) {
		gl_FragColor = color;
		return;
	}
	
	vec4 _cFg  = texture2D( fore, foreCoord );
	     _cFg *= v_vColour;
	
	float al = _cFg.a + _cBg.a * (1. - _cFg.a);
	vec4 res = ((_cFg * _cFg.a) + (_cBg * _cBg.a * (1. - _cFg.a))) / al;
	res.a = al;
	
    gl_FragColor = res;
}
