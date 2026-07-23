varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float threshold;

void main() {
	vec4 colr = texture2D( gm_BaseTexture, v_vTexcoord );
	float val = (colr.r + colr.g + colr.b) * colr.a;
    gl_FragColor = vec4(0., 0., step(threshold, val), 1.);
}