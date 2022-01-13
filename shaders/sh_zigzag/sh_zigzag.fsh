//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float amount;

void main() {
	float _cell  = 1. / (amount * 2.);
	
    float _xind  = floor(v_vTexcoord.x / _cell);
    float _yind  = floor(v_vTexcoord.y / _cell);
	
    float _xcell = mod(v_vTexcoord.x, _cell);
    float _ycell = mod(v_vTexcoord.y, _cell);
	
	float _x = _xcell;
	float _y = _ycell;
	
	if(mod(_xind, 2.) == 1.)
		_x = _cell - _xcell;
	
	if(mod(_yind, 2.) == 1.) {
		if(_x > _y)
			gl_FragColor = vec4(vec3(0.), 1.);
		else
			gl_FragColor = vec4(vec3(1.), 1.);
	} else {
		if(_x > _y)
			gl_FragColor = vec4(vec3(1.), 1.);
		else
			gl_FragColor = vec4(vec3(0.), 1.);
	}
}
