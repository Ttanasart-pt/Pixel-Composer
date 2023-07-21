//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec4 color;

uniform float hash;
uniform int   invert;

void main() {
	vec2 px = v_vTexcoord * dimension;
	float index;
	
	if(invert == 1) index = px.x - px.y;
	else			index = px.x + px.y;
	
	if(mod(index, hash) >= hash / 2.)
		gl_FragColor = color;
	else
		gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
	
}
