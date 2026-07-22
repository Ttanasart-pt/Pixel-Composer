varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int       keepAlpha;
uniform sampler2D original;

void main() {
	vec4 colr = texture2D(gm_BaseTexture, v_vTexcoord);
	
	if(keepAlpha == 1) {
		vec4 orig = texture2D(original, v_vTexcoord);
		colr.a = orig.a;
	}
	
	gl_FragColor = colr;
}