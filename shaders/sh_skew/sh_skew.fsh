//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 center;
uniform int axis;
uniform float amount;
uniform int wrap;

void main() {
	vec2 pos = v_vTexcoord;
	vec2 cnt = center / dimension;
	
	if(axis == 0)
		pos.x += (pos.y - cnt.y) * amount;
	else
		pos.y += (pos.x - cnt.x) * amount;
	
	if(wrap == 1) {
		if(pos.x > 1.) pos.x = fract(pos.x);
		if(pos.x < 0.) pos.x = abs(fract(pos.x));
		if(pos.y > 1.) pos.y = fract(pos.y);
		if(pos.y < 0.) pos.y = abs(fract(pos.y));
	}
	
    gl_FragColor = texture2D( gm_BaseTexture, pos );
}
