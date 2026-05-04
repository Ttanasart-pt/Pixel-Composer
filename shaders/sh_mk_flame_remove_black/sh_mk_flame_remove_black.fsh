varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 cc = texture2D(gm_BaseTexture, v_vTexcoord);
	if((cc.r + cc.g + cc.b) * cc.a <= 0.)
		discard;
	gl_FragColor = cc;
}