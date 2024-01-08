//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 position;
uniform int blend;

uniform vec2      amount;
uniform int       amountUseSurf;
uniform sampler2D amountSurf;

uniform vec4 col1, col2;

void main() {
	float amo = amount.x;
	if(amountUseSurf == 1) {
		vec4 _vMap = texture2D( amountSurf, v_vTexcoord );
		amo = mix(amount.x, amount.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
		
	vec2 pos = v_vTexcoord - position;
	float _cell  = 1. / (amo * 2.);
	
    float _xind  = floor(pos.x / _cell);
    float _yind  = floor(pos.y / _cell);
	
    float _xcell = fract(pos.x * amo * 2.);
    float _ycell = fract(pos.y * amo * 2.);
	
	float _x = _xcell;
	float _y = _ycell;
	
	if(mod(_xind, 2.) == 1.)
		_x = 1. - _xcell;
	
	if(blend == 0) {
		if(mod(_yind, 2.) == 1.) {
			if(_x > _y)	gl_FragColor = col1;
			else		gl_FragColor = col2;
		} else {
			if(_x > _y) gl_FragColor = col2;
			else		gl_FragColor = col1;
		}
	} else {
		if(_x > _y) gl_FragColor = mix(col1, col2, _y + (1. - _x));
		else		gl_FragColor = mix(col1, col2, _y - _x);
	}
}
