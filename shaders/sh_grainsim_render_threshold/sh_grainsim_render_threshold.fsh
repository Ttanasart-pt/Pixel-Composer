varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float threshold;

void main() {
	vec4 base = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	base.a = step(threshold, base.a);
	
	gl_FragColor = base;
}