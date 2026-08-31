varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 spriteSize;
uniform vec2 surfaceSize;
uniform float shift;

void main() {
	vec2 px = v_vTexcoord * surfaceSize;
	vec2 sx = mod(px, spriteSize);
	
	vec2 tx = (sx - shift) / spriteSize;
	tx = fract(fract(tx) + 1.);
	
	gl_FragColor = texture2D(gm_BaseTexture, tx) * v_vColour;
}