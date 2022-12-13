/*
	Triangular Grid
	03/2016
	seb chevrel
*/

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  position;
uniform vec2  scale;
uniform float angle;
uniform float thick;

float hexagonAspect = sqrt(3.0);

void main() {
	float time = 1.;
	vec2 pos = (v_vTexcoord - position), _pos;
	float ratio = dimension.x / dimension.y;
	
	_pos.x = pos.x * ratio * cos(angle) - pos.y * sin(angle);
	_pos.y = pos.x * ratio * sin(angle) + pos.y * cos(angle);
	_pos.y *= hexagonAspect;
	
    vec2 uvTiled = _pos * scale;
    vec2 uvOffset = uvTiled + floor((uvTiled.y) / 1.5) * 0.5;
    vec2 uvChanged = abs(fract(uvOffset) - 0.5) * 2.0;
    
    float hexagonMask = 0.0;
    
    if(mod(uvTiled.y, 1.5) < 1.0) {
    	hexagonMask = step(uvChanged.x, 1.0 - thick);
    }
    else {
        hexagonMask = 
                step(uvChanged.x + thick * hexagonAspect, uvChanged.y) + 
                step(uvChanged.y + thick * hexagonAspect, uvChanged.x);
    }

    gl_FragColor = vec4(vec3(hexagonMask), 1.);
}
