varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  ignore;
uniform int  mode;

float sampVal(vec4 col) { return mode == 1? col.a : length(col.rgb) * col.a; }

void main() {
	vec2 px = v_vTexcoord * dimension - .5;
	
	gl_FragColor = vec4(0.);
	if(ignore == 0 || sampVal(texture2D( gm_BaseTexture, v_vTexcoord )) != 0.)
		gl_FragColor = vec4(px.x, px.y, px.x, px.y);
}
 