varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D baseSurface;

void main() {
	vec4 base = texture2D(baseSurface, v_vTexcoord);
	vec4 mask = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = vec4(mask.rgb, base.a) * v_vColour;
}