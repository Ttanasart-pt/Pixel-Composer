varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int grey;

void main() {
	vec2 tx  = vec2(v_vTexcoord.x, 1. - v_vTexcoord.y);
	vec4 col = texture2D(gm_BaseTexture, tx);
	
	if(grey == 1) col = vec4(col.r, col.g, col.b, 1.);
	gl_FragColor = col;
}