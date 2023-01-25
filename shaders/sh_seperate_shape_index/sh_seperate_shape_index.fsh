//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int ignore;

float sampVal(vec4 col) { return length(col.rgb) * col.a; }

void main() {
	if(ignore == 1 && sampVal(texture2D( gm_BaseTexture, v_vTexcoord )) == 0.)
		gl_FragColor = vec4(0.);
	else
		gl_FragColor = vec4(v_vTexcoord.x, v_vTexcoord.y, v_vTexcoord.x, v_vTexcoord.y);
}
