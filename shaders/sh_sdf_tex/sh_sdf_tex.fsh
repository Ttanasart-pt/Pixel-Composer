varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 colr = texture2D( gm_BaseTexture, v_vTexcoord );
	float val = (colr.r + colr.g + colr.b) * colr.a;
    gl_FragColor = vec4(0., 0., step(0.5, val), 1.);
}