//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D fore;
uniform vec2 dimension;
uniform vec2 fdimension;
uniform vec2 position;

void main() {
	vec2 px  = v_vTexcoord * dimension;
	vec2 fpx = px - position;
	vec2 ftx = fpx / fdimension;
	
	vec4 _cBg = texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(ftx.x < 0. || ftx.y < 0. || ftx.x > 1. || ftx.y > 1.) {
		gl_FragColor = _cBg;
		return;
	}
	
	vec4 _cFg = texture2D( fore, ftx );
	float al  = _cFg.a + _cBg.a * (1. - _cFg.a);
	vec4 res  = (_cFg * _cFg.a) + (_cBg * _cBg.a * (1. - _cFg.a));
	res = vec4(res.rgb / al, al);
	
	gl_FragColor = res;
}
