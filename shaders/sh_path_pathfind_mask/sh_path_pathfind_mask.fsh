varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 col = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	float a  = length(col.rgb) * col.a;
	gl_FragColor = vec4(a,a,a,1.);
}