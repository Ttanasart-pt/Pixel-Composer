varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

uniform int   axis;
uniform vec2  origin;
uniform float amount;

float round(float x) { return x >= 0.? floor(x) : floor(x) + 1.; }

void main() {
	vec2 px = v_vTexcoord * dimension;
	vec2 amo;
	
		 if(axis == 0) amo = vec2(round(amount * (px.y - origin.y)), 0.);
	else if(axis == 1) amo = vec2(0., round(amount * (px.x - origin.x)));
	
	gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord - amo / dimension);
}
