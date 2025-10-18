varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  position;
uniform int   blend;
uniform float rotation;
uniform float threshold;

uniform vec2      amount;
uniform int       amountUseSurf;
uniform sampler2D amountSurf;

uniform vec2      angle;
uniform int       angleUseSurf;
uniform sampler2D angleSurf;

uniform vec4 col1, col2;

void main() {
	#region params
		float amo = amount.x;
		if(amountUseSurf == 1) {
			vec4 _vMap = texture2D( amountSurf, v_vTexcoord );
			amo = mix(amount.x, amount.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		amo = dimension.x / amo;
		
		float ang = angle.x;
		if(angleUseSurf == 1) {
			vec4 _vMap = texture2D( angleSurf, v_vTexcoord );
			ang = mix(angle.x, angle.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		ang = radians(ang);
	#endregion
	
	vec2 asp = vec2(dimension.x / dimension.y, 1.);
	vec2 vtx = floor(v_vTexcoord * dimension) / dimension;
	vec2 pos = (vtx - position) * asp;
	float _cell  = 1. / (amo * 2.); 
	pos.y -= _cell / 2.;
	pos   *= mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
	
    float _xind  = floor(pos.x / _cell);
    float _yind  = floor(pos.y / _cell);
	
    float _xcell = fract(pos.x * amo * 2.);
    float _ycell = fract(pos.y * amo * 2.);
	
	float _x = _xcell;
	float _y = _ycell;
	
	if(mod(_xind, 2.) == 1.)
		_x = 1. - _xcell;
	
	float _h = _x > _y? _y + (1. - _x) : _y - _x;
	      
	float _ychi = _x > _y ? _yind + 1. : _yind;
	if(mod(_ychi, 2.) == 1.) _h = 1. - _h;
	
	if(blend == 0) {
		gl_FragColor = _h < threshold? col1 : col2;
		
	} else if(blend == 1) {
		gl_FragColor = mix(col1, col2, _h);
		
	} else if(blend == 2) { 
		float px = 1. / max(dimension.x, dimension.y);
		_h = smoothstep(threshold - px, threshold + px, _h);
			
		gl_FragColor = mix(col1, col2, _h);
	}
}
