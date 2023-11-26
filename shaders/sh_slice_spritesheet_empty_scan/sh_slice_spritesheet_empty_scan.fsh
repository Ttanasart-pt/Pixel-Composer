//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 paddingStart;
uniform vec2 spacing;
uniform vec2 spriteDim;
uniform vec4 color;
uniform int  empty;

void main() {
	vec2 px   = v_vTexcoord * dimension - 0.5;
	vec2 cls  = floor((px - paddingStart) / (spriteDim + spacing)) * (spriteDim + spacing);
	
	gl_FragColor = vec4(0.);
	
	for(float i = 0.; i < spriteDim.x; i++)
	for(float j = 0.; j < spriteDim.y; j++) {
		vec2 tx = (cls + vec2(i, j)) / dimension;
		vec4 col = texture2D( gm_BaseTexture, tx );
		
		if((empty == 1 && col.a != 0.) || (empty == 0 && col != color)) {
			gl_FragColor = col;
			return;
		}
	}
}
