varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  sampleColor;
uniform float threshold;

bool colorMatch(vec4 c1, vec4 c2) { return distance(c1.rgb * c1.a, c2.rgb * c2.a) <= threshold; }

void main() {
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	float b = colorMatch(base, sampleColor)? 1. : 0.;
	gl_FragColor = vec4(b);
}