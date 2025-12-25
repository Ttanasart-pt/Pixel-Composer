varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int tileX;
uniform int tileY;
uniform int tileR;

void main() {
	vec2 tx = v_vTexcoord;
	if(tileX == 1) tx.x = 1. - tx.x;
	if(tileY == 1) tx.y = 1. - tx.y;
	if(tileR == 1) tx = vec2(tx.y, 1. - tx.x);

	gl_FragColor = v_vColour * texture2D(gm_BaseTexture, tx);
}