varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float rotation;
uniform int flipx;
uniform int flipy;
				
void main() {
	float ang = radians(rotation);
	vec2  tx  = (v_vTexcoord - .5) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) + .5;
	
	if (flipx == 1) tx.x = 1. - tx.x;
	if (flipy == 1) tx.y = 1. - tx.y;
	
	gl_FragColor = v_vColour * texture2D(gm_BaseTexture, tx);
}