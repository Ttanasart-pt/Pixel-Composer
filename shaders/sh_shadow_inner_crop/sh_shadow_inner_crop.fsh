varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D original;

void main() {
	vec4 orig = texture2D(original, v_vTexcoord);
	vec4 shad = texture2D(gm_BaseTexture, v_vTexcoord);
	shad.a = (1. - shad.a) * orig.a;
	
	gl_FragColor = shad;
}